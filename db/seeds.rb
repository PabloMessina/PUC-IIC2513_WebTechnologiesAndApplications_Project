r = new Random(1234)    # seed


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
        name: Faker::Company.name
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

bananas = Product.create!(
    name: 'Bananas',
    price: 600,
    grocery_id: trader_joes.id,
    category_id: fruit.id
)
set_tag(bananas, offer)
Inventory.create!(product_id: bananas.id, stock: 6)
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

corn = Product.create!(
    name: 'Corn',
    price: 590,
    grocery_id: trader_joes.id,
    category_id: vegetable.id
)
