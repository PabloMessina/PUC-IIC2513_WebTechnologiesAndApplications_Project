srand 1234  # random seed


# users

tomas = User.create!(
  first_name: 'Tomás',
  last_name: 'A.',
  username: 'tandrighetti',
  password: 'password',
  password_confirmation: 'password',
  email: 'taandrighetti@uc.cl',
  address: 'mi casa'
)

pablo = User.create!(
  first_name: 'Pablo',
  last_name: 'Messina',
  username: 'pamessina',
  password: 'password',
  password_confirmation: 'password',
  email: 'pamessina@uc.cl',
  address: 'mi casa'
)

3.times do
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


# groceries

trader_joes = Grocery.create!(
    name: "Trader Joe's",
    address: '5976 Konopelski Centers'
)
Privilege.create!(
    user_id: pablo.id,
    grocery_id: trader_joes.id,
    privilege: Privilege.privileges[:administrator]
)

norton_groceries = Grocery.create!(
    name: 'Norton Groceries',
    address: '3701 Hattie Isle'
)
Privilege.create!(
    user_id: tomas.id,
    grocery_id: norton_groceries.id,
    privilege: Privilege.privileges[:administrator]
)

# otras
6.times do
    Grocery.create!(
        name: Faker::Company.name,
        address: 'no'
    )
end


# categories

fruit = Category.create!(name: 'Fruit')
vegetable = Category.create!(name: 'Vegetable')
#despensa = Category.create!(name: 'despensa??????????')
despensa = Category.create!(name: 'grocery')


# tags

offer = Tag.create!(name: 'offer')

def set_tag(product, tag)
    Product::HABTM_Tags.create!(
        product_id: product.id,
        tag_id: tag.id
    )
end


# products

apples = Product.create!(
    name: 'Apples',
    price: 1600,
    grocery_id: trader_joes.id,
    category_id: fruit.id
)
Inventory.create!(product_id: apples.id, stock: 30)
apples = Product.create!(
    name: 'Apples',
    price: 1700,
    grocery_id: norton_groceries.id,
    category_id: fruit.id
)
Inventory.create!(product_id: apples.id, stock: 40)

bananas_tj = Product.create!(
    name: 'Bananas',
    price: 600,
    grocery_id: trader_joes.id,
    category_id: fruit.id
)
set_tag(bananas_tj, offer)
Inventory.create!(product_id: bananas_tj.id, stock: 6)
bananas = Product.create!(
    name: 'Bananas',
    price: 900,
    grocery_id: norton_groceries.id,
    category_id: fruit.id
)
Inventory.create!(product_id: bananas.id, stock: 24)

carrots = Product.create!(
    name: 'Carrots',
    price: 1000,
    grocery_id: trader_joes.id,
    category_id: vegetable.id
)
Inventory.create!(product_id: carrots.id, stock: 12)
carrots = Product.create!(
    name: 'Carrots',
    price: 900,
    grocery_id: norton_groceries.id,
    category_id: vegetable.id
)
Inventory.create!(product_id: carrots.id, stock: 15)

celery = Product.create!(
    name: 'Celery',
    price: 1300,
    grocery_id: trader_joes.id,
    category_id: vegetable.id
)
Inventory.create!(product_id: celery.id, stock: 60)
celery = Product.create!(
    name: 'Celery',
    price: 1400,
    grocery_id: norton_groceries.id,
    category_id: vegetable.id
)
Inventory.create!(product_id: celery.id, stock: 50)

leche_entera = Product.create!(
    name: "Leche entera",
    price: 810,
    grocery_id: trader_joes.id,
    category_id: despensa.id
)
Inventory.create!(product_id: leche_entera.id, stock: 123)

leche_semidescremada = Product.create!(
    name: "Leche semidescremada",
    price: 810,
    grocery_id: trader_joes.id,
    category_id: despensa.id
)
Inventory.create!(product_id: leche_semidescremada.id, stock: 87)

leche_descremada = Product.create!(
    name: "Leche descremada",
    price: 810,
    grocery_id: trader_joes.id,
    category_id: despensa.id
)
Inventory.create!(product_id: leche_descremada.id, stock: 46)

corn = Product.create!(
    name: 'Corn',
    price: 590,
    grocery_id: norton_groceries.id,
    category_id: vegetable.id
)
Inventory.create!(product_id: corn.id, stock: 42)


# reports

r = Report.create!(
    title: 'Nos cambiamos de local',
    text: 'La nueva dirección es 5976 Konopelski Centers',
    grocery_id: trader_joes.id,
    created_at: 1.year.ago
)

Report.create!(
    title: 'Plátanos en oferta',
    text: 'Oferta solo hasta agotar stock',
    product_id: bananas_tj.id,
    grocery_id: trader_joes.id,
    created_at: 2.days.ago
)













Product.all.each do |p|

    # reviews aaaaAAaaaAAaarg
    u=1
    rand(0..4).times do |i|
        p.reviews.create!(content: Faker::Lorem.paragraph(2, true, 4),
            title: Faker::Lorem.paragraph(1, true, 1),
            user_id: u, rating: rand(1..5))
        u+=1
    end


end

def time_rand from = 2.years.ago, to = Time.now
  Time.at(from + rand * (to.to_f - from.to_f))
end
def rand_id(model)
  rand(1..model.last.id)
end

Grocery.all.each do |g|
    20.times do
      po = g.purchase_orders.create!(user_id: rand_id(User), order_lines_data: "[]", skip_check_order_lines: true, created_at: time_rand)
      4.times do
        p = Product.find_by_id(rand_id(Product))
        po.order_lines.create!(product_id: p.id, amount: 11 + rand(100), product_price: p.price)
      end
    end
end
