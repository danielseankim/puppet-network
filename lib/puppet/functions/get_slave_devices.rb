Puppet::Functions.create_function(:get_slave_devices) do
  dispatch :get_slave_devices do
    param 'String', :macaddresses
  end

  def get_slave_devices(macaddresses)
    result = []
    macaddresses.split(",").each do |mac|
      dev = call_function("map_macaddr_to_interface", mac)
      result << dev
    end

    result
  end
end
