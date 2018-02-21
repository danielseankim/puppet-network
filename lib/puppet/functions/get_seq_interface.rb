Puppet::Functions.create_function(:get_seq_interface) do
  dispatch :get_seq_interface do
    param 'String', :seq_string
    return_type 'String'
  end

  def get_seq_interface(seq_string)
    # because of stability issue around parameter fetch and automatic conversion, we pass String in and convert manually
    seq = Integer(seq_string)
    interfaces = closure_scope["facts"]["networking"]["interfaces"]
    call_function("notice", "get_seq_interface.rb: look for an interface with sequence, #{seq_string}, from #{interfaces}")
    interfaces.reject { |ifn| ifn == "lo" }.sort[seq]
  end
end
