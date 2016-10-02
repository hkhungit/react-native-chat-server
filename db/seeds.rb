User.destroy_all
Chat.destroy_all
Message.destroy_all

peter = User.create({fullname: 'Peter Parker', username: 'peter', password: '123', status: 'My name is Peter'})
cech = User.create({fullname: 'Petr Cech', username: 'cech', password: '123', status: 'Hello react native'})
david = User.create({fullname: 'David Ospina', username: 'david', password: '123', status: 'Hello react native'})
shkodran = User.create({fullname: 'Shkodran Mustafi', username: 'shkodran', password: '123', status: 'Hello react native'})
hector = User.create({fullname: 'Héctor Bellerín', username: 'hector', password: '123', status: 'Hello react native'})

cech.friends  = [peter.format_item, david.format_item]
cech.inviters   = [shkodran.format_item, hector.format_item]

peter.friends = [cech.format_item, david.format_item]
peter.inviters  = [shkodran.format_item, hector.format_item]
david.friends = [peter.format_item, cech.format_item]
david.inviters  = [shkodran.format_item, hector.format_item]
cech.save
peter.save
david.save

Chat.create({type: :single, users: [cech, peter]})
Chat.create({type: :single, users: [cech, david]})
Chat.create({type: :single, users: [cech, shkodran]})
Chat.create({type: :single, users: [cech, hector]})
Chat.create({type: :single, users: [peter, hector]})
Chat.create({type: :single, users: [peter, david]})
Chat.create({type: :single, users: [peter, shkodran]})
Chat.create({type: :single, users: [shkodran, hector]})