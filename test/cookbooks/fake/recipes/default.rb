include_recipe 'opendkim::default'

opendkim_key 'transactional_i3mm.com' do
  selector 'transactional'
  domain 'i3mm.com'
end

opendkim_key 'transactional_rodeopartners.com' do
  selector 'transactional'
  domain 'rodeopartners.com'
end
