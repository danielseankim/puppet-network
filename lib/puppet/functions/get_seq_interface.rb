Puppet::Functions.create_function(:get_seq_interface) do
  dispatch :get_seq_interface do
    param 'String', :seq_string
  end

  def get_seq_interface(seq_string)
    seq = Integer(seq_string)
    interfaces = closure_scope["facts"]["interfaces"]
    interfaces.split(",").reject { |ifn| ifn == "lo" }.sort[seq]
  end
end
