require 'rspec'

describe 'Identities test' do
  def to_json(identity)
    {
      account: identity.account,
      alias: identity.alias,
      api_id: identity.api_id,
      country_iso: identity.country_iso,
      document_details: identity.document_details,
      first_name: identity.first_name,
      id: identity.id,
      id_number: identity.id_number,
      id_type: identity.id_type,
      last_name: identity.last_name,
      nationality: identity.nationality,
      salutation: identity.salutation,
      subaccount: identity.subaccount,
      url: identity.url,
      validation_status: identity.validation_status,
      verification_status: identity.verification_status
    }.reject { |_, v| v.nil? }.to_json
  end

  def to_json_update(identity)
    {
        api_id: identity.api_id,
        message: identity.message
    }.reject { |_, v| v.nil? }.to_json
  end

  def to_json_create(identity)
    {
        api_id: identity.api_id,
        message: identity.message
    }.reject { |_, v| v.nil? }.to_json
  end

  def to_json_list(list_object)
    objects_json = list_object[:objects].map do |object|
      obj = JSON.parse(to_json(object))
      obj.delete('api_id')
      obj.reject { |_, v| v.nil? }
    end
    {
        api_id: list_object[:api_id],
        meta: list_object[:meta],
        objects: objects_json
    }.to_json
  end

  it 'creates an identity' do
    contents = File.read(Dir.pwd + '/spec/mocks/identityCreateResponse.json')
    mock(200, JSON.parse(contents))

    expect(JSON.parse(to_json_create(@api.identities
                                         .create(
                                             'US',
                                             'Mr',
                                             'Bruce',
                                             'Wayne',
                                             'Gotham City',
                                             '1900-01-01',
                                             'US',
                                             'American',
                                             '1900-01-01',
                                             'others',
                                             'BATMANRETURNS',
                                             '1234',
                                             'Wayne Towers',
                                             'New York',
                                             'NY',
                                             '12345',
                                             nil,
                                             {
                                                 callback_url: 'https://callback.url',
                                             }
                                         ))))
        .to eql(JSON.parse(contents).reject { |_, v| v.nil? })
    compare_requests(uri: '/v1/Account/MAXXXXXXXXXXXXXXXXXX/Verification/Identity/',
                     method: 'POST',
                     data: {
                         country_iso: 'US',
                         salutation: 'Mr',
                         first_name: 'Bruce',
                         last_name: 'Wayne',
                         birth_place: 'Gotham City',
                         birth_date: '1900-01-01',
                         nationality: 'US',
                         id_nationality: 'American',
                         id_issue_date: '1900-01-01',
                         id_type: 'others',
                         id_number: 'BATMANRETURNS',
                         address_line1: '1234',
                         address_line2: 'Wayne Towers',
                         city: 'New York',
                         region: 'NY',
                         postal_code: '12345',
                         callback_url: 'https://callback.url'
                     })
  end

  it 'fetches details of an identity' do
    contents = File.read(Dir.pwd + '/spec/mocks/identityGetResponse.json')
    mock(200, JSON.parse(contents))
    expect(JSON.parse(to_json(@api.identities.get('12345'))))
        .to eql(JSON.parse(contents).reject { |_, v| v.nil? })
    compare_requests(uri: '/v1/Account/MAXXXXXXXXXXXXXXXXXX/Verification/Identity/'\
                     '12345/',
                     method: 'GET',
                     data: nil)
  end

  it 'lists all identities' do
    contents = File.read(Dir.pwd + '/spec/mocks/identityListResponse.json')
    mock(200, JSON.parse(contents))
    response = to_json_list(@api.identities.list)

    contents = JSON.parse(contents)
    objects = contents['objects'].map do |obj|
      obj.delete('api_id')
      obj.reject { |_, v| v.nil? }
    end
    contents['objects'] = objects

    expect(JSON.parse(response).reject { |_, v| v.nil? })
        .to eql(contents)
    compare_requests(uri: '/v1/Account/MAXXXXXXXXXXXXXXXXXX/Verification/Identity/',
                     method: 'GET',
                     data: nil)
  end

  it 'updates the identity' do
    id = '12345'
    contents = File.read(Dir.pwd + '/spec/mocks/identityUpdateResponse.json')
    mock(200, JSON.parse(contents))
    expect(JSON.parse(to_json_update(@api.identities
                                         .update(id, nil,
                                                 {
                                                     salutation: 'Mr',
                                                    first_name: 'Bruce'
                                                 }
                                                 ))))
        .to eql(JSON.parse(contents).reject { |_, v| v.nil? })
    compare_requests(uri: '/v1/Account/MAXXXXXXXXXXXXXXXXXX/Verification/Identity/' + id + '/',
                     method: 'POST',
                     data: {
                         salutation: 'Mr',
                         first_name: 'Bruce'
                     })
  end

  it 'deletes the identity' do
    id = '12345'
    contents = '{}'
    mock(204, JSON.parse(contents).reject { |_, v| v.nil? })
    @api.identities.delete(id)
    compare_requests(uri: '/v1/Account/MAXXXXXXXXXXXXXXXXXX/Verification/Identity/' + id + '/',
                     method: 'DELETE',
                     data: nil)
  end
end
