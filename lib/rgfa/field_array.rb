# Array representing multiple values of the same tag in different header lines
class RGFA::FieldArray < Array
  attr_reader :datatype

  # @param datatype [RGFA::Line::OPTFIELD_DATATYPE] the datatype to use
  def initialize(datatype, data = [])
    @datatype = datatype
    super(data)
  end

  # Run a datatype-specific validation on each element of the array
  # @param datatype [RGFA::Line::OPTFIELD_DATATYPE]
  def validate_gfa_field!(datatype, fieldname=nil)
    each.validate_gfa_field!(@datatype, fieldname)
  end

  # Default datatype, in this case :J
  # @api private
  def default_gfa_datatype
    :J
  end

  # Representation of the field array as JSON array, with
  # two additional values: the datatype and a zero byte as "signature".
  # @param datatype [RGFA::Line::OPTFIELD_DATATYPE] (ignored, J is always used)
  # @api private
  def to_gfa_field(datatype: nil)
    self << @datatype
    self << "\0"
    to_json
  end

  # Add a value to the array and validate
  # @raise [RGFA::FieldArray::TypeMismatchError] if the type
  #   of the new value does not correspond to the type of
  #   existing values
  # @param value [Object] the value to add
  # @param type [RGFA::Line::OPTFIELD_DATATYPE, nil] the datatype to use;
  #   if not +nil+, it will be checked that the specified datatype is the
  #   same as for previous elements of the field array;
  #   if +nil+, the value will be validated, according to the datatype
  #   specified on field array creation
  # @param fieldname [Symbol] the field name to use for error messages
  #
  def push_with_validation(value, type, fieldname=nil)
    if type.nil?
      value.validate_gfa_field!(@datatype, fieldname)
    elsif type != @datatype
      raise RGFA::FieldArray::TypeMismatchError,
        "Datatype mismatch error for field #{fieldname}:\n"+
        "value: #{value}\n"+
        "existing datatype: #{@datatype};\n"+
        "new datatype: #{type}"
    end
    self << value
  end
end

# Generic error associated with field arrays
class RGFA::FieldArray::Error < RGFA::Error; end

# Error raised when trying to add elements with a wrong datatype
class RGFA::FieldArray::TypeMismatchError < RGFA::Error; end

class Array
  # Is this possibly a {RGFA::FieldArray} instance?
  #
  # (i.e. are the two last elements a datatype symbol
  # and a zero byte?)
  # @return [Boolean]
  def rgfa_field_array?
    self[-1] == "\0" and
      RGFA::Line::OPTFIELD_DATATYPE.include?(self[-2].to_sym)
  end

  # Create a {RGFA::FieldArray} from an array
  # @param datatype [RGFA::Line::OPTFIELD_DATATYPE, nil] the datatype to use
  def to_rgfa_field_array(datatype=nil)
    if self.rgfa_field_array?
      RGFA::FieldArray.new(self[-2].to_sym, self[0..-3])
    elsif datatype.nil?
      raise RGFA::FieldArray::Error, "no datatype specified"
    else
      RGFA::FieldArray.new(datatype, self)
    end
  end
end
