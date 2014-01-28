include_recipe 'opendkim::default'

opendkim_key 'transactional_i3mm.com' do
  selector 'transactional'
  domain 'i3mm.com'
end

opendkim_key 'transactional_rodeopartners.com' do
  selector 'transactional'
  domain 'rodeopartners.com'
end

opendkim_key 'mail@rodeopartners.com' do
  selector 'mail'
  domain 'rodeopartners.com'
  private_key 'test private key 2'
  signatures %w{ rodeopartners.com i3mm.com }
end

opendkim_key 'nonexistant@rodeopartners.com' do
  selector 'nonexistant'
  domain 'rodeopartners.com'
  private_key 'test private key'
end
