NUM_USERS             = 10
NUM_GROCERIES         = 4
NUM_CATEGORIES        = 5
NUM_TAGS              = 8
RANGE_PRODUCTS        = 3..15
MAX_PRODUCTS          = 15
MAX_TAGS              = 3
RANGE_REPORTS         = 3..15
RANGE_REPORT_COMMENTS = 0..3
NUM_PURCHASE_ORDERS   = 25
NUM_ORDER_LINES       = 5
RANGE_FOLLOWERS       = 0..6


puts "Seeding..."

NUM_USERS.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  User.create!(
    first_name: first_name,
    last_name: last_name,
    username: (first_name[0] + last_name).downcase,
    password: 'password',
    password_confirmation: 'password',
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
  password: 'password',
  password_confirmation: 'password',
  email: 'c@c.c',
  address: 'd')

User.create!(
  first_name: 'Tomás',
  last_name: 'A.',
  username: 'tandrighetti',
  password: 'password',
  password_confirmation: 'password',
  email: 'taandrighetti@uc.cl',
  address: 'mi casa')

User.create!(
  first_name: 'Pablo',
  last_name: 'Messina',
  username: 'pamessina',
  password: 'password',
  password_confirmation: 'password',
  email: 'pamessina@uc.cl',
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

  n_products = rand(g.id == 1 ? 11..35 : RANGE_PRODUCTS)
  n_products.times do
    p = Product.create!(
      name: Faker::Commerce.product_name,
      description: Faker::Lorem.word,
      price: rand(1..100) * 50,
      grocery_id: g.id,
      category_id: rand_id(Category))

    Inventory.create!(product_id: p.id, stock: rand(0..100))

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
    r = Report.create!(params)

    rand(RANGE_REPORT_COMMENTS).times do
      Comment.create!(text: Faker::Lorem.sentence,
        user_id: rand(1..NUM_USERS),
        report_id: r.id)
    end
  end

  return g
end

create_grocery(User.find_by_username('a').id)

NUM_GROCERIES.times do
  g = create_grocery(rand(1..NUM_USERS))    # owners: random users

  NUM_PURCHASE_ORDERS.times do
    po = g.purchase_orders.create!(user_id: rand_id(User), order_lines_data: "[]", skip_check_order_lines: true)
    NUM_ORDER_LINES.times do
      p = Product.find_by_id(rand_id(Product))
      po.order_lines.create!(product_id: p.id, amount: 11 + rand(100), product_price: p.price)
    end
  end

  g.products.each do |p|
    user_id = rand(NUM_USERS)+1
    p.reviews.create!(content: Faker::Lorem.paragraph(2, true, 4),
      title: Faker::Hacker.say_something_smart,
      user_id: user_id, rating: rand(1..5))

    user_id += 1
    user_id = 1 if user_id == NUM_USERS + 1

    p.reviews.create!(content: Faker::Lorem.paragraph(2, true, 4),
      title: Faker::Hacker.say_something_smart,
      user_id: user_id, rating: rand(1..5))

    user_id += 1
    user_id = 1 if user_id == NUM_USERS + 1

    p.reviews.create!(content: Faker::Lorem.paragraph(2, true, 4),
    title: Faker::Hacker.say_something_smart,
    user_id: user_id, rating: rand(1..5))

    user_id += 1
    user_id = 1 if user_id == NUM_USERS + 1

    p.stars.create!(user_id: user_id, value: rand(1..5))

    user_id += 1
    user_id = 1 if user_id == NUM_USERS + 1

    p.stars.create!(user_id: user_id, value: rand(1..5))

  end

end

User.find_each do |user|
  Follower.create(
    user_id: user.id,
    grocery_id:  Grocery.order("RANDOM()").first.id)
end
