NUM_USERS       = 10
NUM_GROCERIES   = 4
NUM_CATEGORIES  = 5
NUM_TAGS        = 8
RANGE_PRODUCTS  = 3..15
MAX_PRODUCTS    = 15
MAX_TAGS        = 3
RANGE_REPORTS   = 3..15


puts "Seeding..."

NUM_USERS.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  User.create!(
    first_name: first_name,
    last_name: last_name,
    username: (first_name[0] + last_name).downcase,
    password: 'dbseed',
    password_confirmation: 'dbseed',
    email: Faker::Internet.email(first_name),
    address: Faker::Address.street_address)
end

User.create!(
  first_name: 'a',
  last_name: 'b',
  username: 'a',
  password: 'bbbbbb',
  password_confirmation: 'bbbbbb',
  email: 'a@a.a',
  address: 'b')

User.create!(
  first_name: 'c',
  last_name: 'd',
  username: 'c',
  password: 'dddddd',
  password_confirmation: 'dddddd',
  email: 'c@c.c',
  address: 'd')

User.create!(
  first_name: 'Tomás',
  last_name: 'A.',
  username: 'tandrighetti',
  password: '111111',
  password_confirmation: '111111',
  email: 'taandrighetti@uc.cl',
  address: 'mi casa')


NUM_CATEGORIES.times do
  Category.create!(name: 'dbseed:' + Faker::Commerce.department(1))
end

NUM_TAGS.times do |i|
  Tag.create!(name: 'dbseed:Tag' + i.to_s)
end

def rand_id(model)
  rand(1..model.last.id)
end

def create_grocery(owner_id)
  g = Grocery.create!(
    name: Faker::Company.name,
    address: Faker::Address.street_address)

  Privilege.create!(
    user_id: owner_id,
    grocery_id: g.id,
    privilege: Privilege.privileges[:administrator])

  # TODO: imagenes
  #GroceryImage.create!(
  #  grocery_image: Faker::Company.logo,
  #  grocery_id: g.id)

  n_products = rand(g.id == 1 ? 11..35 : RANGE_PRODUCTS)
  n_products.times do
    p = Product.create!(
      name: Faker::Commerce.product_name,
      stock: rand(0..100),
      unit: rand(1..Product.units.values.max),
      price: rand(1..100) * 50,
      grocery_id: g.id,
      category_id: rand_id(Category))

    # TODO: imagenes

    n_tags = rand(0..MAX_TAGS)
    n_tags.times do
      begin
        Product::HABTM_Tags.create!(
          product_id: p.id,
          tag_id: rand_id(Tag))
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  n_reports= rand(g.id == 1 ? 6..18 : RANGE_REPORTS)
  n_reports.times do
    title = Faker::Lorem.sentence(rand(2..5)).chomp('.')
    text = ""
    rand(3..10).times do
      text += Faker::Lorem.sentence(rand(2..30)) + "\n"*rand(1..2)     # one or two newlines
    end
    params = { title: title, text: text, grocery_id: g.id }
    if rand(0..1) == 1
      params[:product_id] = Product.where(grocery_id: g.id).order("RANDOM()").first.id
    end
    Report.create!(params)
  end
end

create_grocery(User.find_by_username('a').id)

NUM_GROCERIES.times do
  create_grocery(rand(1..NUM_USERS))    # owners: random users
end
