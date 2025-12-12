Config = {
    VersionCheck = true,     -- Enable/disable automatic version checking for updates
    DefaultLocale = "en",    -- Default locale for the register system ("en" for English, "es" for Spanish, "tr" for Turkish, "ar" for Arabic)

    Registers = {
        burgershot = {
            id = "1",
            label = "Burgershot",
            jobRequired = "burgershot",
            openingMethod = "boxzone",
            locations = {
                { coords = vector3(-1197.46, -892.53, 14.14), heading = 35.0 },
                { coords = vector3(-1190.0, -895.0, 13.0), heading = 35.0 }
            },
            menuItems = {
                { id = "burger_bleeder", name = "Bleeder Burger", price = 8.50, imageUrl = "nui://qb-inventory/html/images/burger_bleeder.png", category = "burgers" },
                { id = "cheeseburger", name = "Cheeseburger", price = 7.50, imageUrl = "nui://qb-inventory/html/images/cheeseburger.png", category = "burgers" },
                { id = "chickenburger", name = "Chicken Burger", price = 7.00, imageUrl = "nui://qb-inventory/html/images/chickenburger.png", category = "burgers" },
                { id = "bacon_cheeseburger", name = "Bacon Cheeseburger", price = 9.00, imageUrl = "nui://qb-inventory/html/images/bacon_cheeseburger.png", category = "burgers" },
                { id = "burger_heartstopper", name = "Heart Stopper", price = 12.00, imageUrl = "nui://qb-inventory/html/images/burger_heartstopper.png", category = "burgers" },
                { id = "steakburger", name = "Steak Burger", price = 10.50, imageUrl = "nui://qb-inventory/html/images/steakburger.png", category = "burgers" },
                { id = "tripleburger", name = "Triple Burger", price = 13.50, imageUrl = "nui://qb-inventory/html/images/tripleburger.png", category = "burgers" },
                { id = "burger_shotrings", name = "Shot Rings", price = 4.00, imageUrl = "nui://qb-inventory/html/images/burger_shotrings.png", category = "sides" },
                { id = "burger_shotnuggets", name = "Shot Nuggets", price = 5.50, imageUrl = "nui://qb-inventory/html/images/burger_shotnuggets.png", category = "sides" },
                { id = "basket_fries", name = "Basket of Fries", price = 3.50, imageUrl = "nui://qb-inventory/html/images/basket_fries.png", category = "sides" },
                { id = "cheese_fries", name = "Cheese Fries", price = 5.00, imageUrl = "nui://qb-inventory/html/images/cheese_fries.png", category = "sides" },
                { id = "burger_softdrink", name = "Soft Drink", price = 2.50, imageUrl = "nui://qb-inventory/html/images/burger_softdrink.png", category = "drinks" },
                { id = "burger_icecream", name = "Ice Cream", price = 3.00, imageUrl = "nui://qb-inventory/html/images/burger_icecream.png", category = "desserts" },
                { id = "cone_chocolate", name = "Chocolate Ice Cream Cone", price = 2.50, imageUrl = "nui://qb-inventory/html/images/cone_chocolate.png", category = "desserts" },
                { id = "cone_blueberry", name = "Blueberry Ice Cream Cone", price = 2.50, imageUrl = "nui://qb-inventory/html/images/cone_blueberry.png", category = "desserts" },
                { id = "burger_rimjob", name = "Rim Job", price = 4.50, imageUrl = "nui://qb-inventory/html/images/burger_rimjob.png", category = "desserts" }
            },
            categories = {
                burgers = "Burgers",
                sides = "Sides",
                drinks = "Drinks",
                desserts = "Desserts"
            }
        },

        --[[
        beanmachine = {
            id = "2",                                    -- Unique identifier for this register (must be different from others)
            label = "Bean Machine",                       -- Display name shown in the UI
            jobRequired = "beanmachine",                  -- Job name required to access this register (from qb-core/shared/jobs.lua)
            openingMethod = "target",                     -- "target" for cash register prop target, "boxzone" for boxzone areas to be targettable
            locations = {                                 -- Array of locations where this register can be accessed
                { coords = vector3(-635.0, 236.0, 81.0), heading = 180.0 }  -- Vector3 coordinates and heading direction
            },
            menuItems = {                                 -- Array of all menu items available at this register
                { id = "muffin", name = "Chocolate Muffin", price = 3.50, imageUrl = "nui://qb-inventory/html/images/muffin.png", category = "pastries" },
                { id = "croissant", name = "Butter Croissant", price = 3.00, imageUrl = "nui://qb-inventory/html/images/croissant.png", category = "pastries" },
                { id = "baquette", name = "Baguette", price = 2.50, imageUrl = "nui://qb-inventory/html/images/baquette.png", category = "pastries" },
                { id = "cb_donut", name = "Chocolate Donut", price = 2.00, imageUrl = "nui://qb-inventory/html/images/cb_donut.png", category = "pastries" },
                { id = "cakepop", name = "Cake Pop", price = 2.50, imageUrl = "nui://qb-inventory/html/images/cakepop.png", category = "pastries" },
                { id = "bean_coffee2", name = "Classic Bean Coffee", price = 3.50, imageUrl = "nui://qb-inventory/html/images/bean_coffee2.png", category = "coffee" },
                { id = "bean_carmalcoffee", name = "Caramel Coffee", price = 4.00, imageUrl = "nui://qb-inventory/html/images/bean_carmalcoffee.png", category = "coffee" },
                { id = "cheesecake", name = "Cheesecake", price = 6.00, imageUrl = "nui://qb-inventory/html/images/cheesecake.png", category = "desserts" },
                { id = "cremecaramel", name = "Crème Caramel", price = 5.50, imageUrl = "nui://qb-inventory/html/images/cremecaramel.png", category = "desserts" },
                { id = "cake_chocolate", name = "Chocolate Cake", price = 7.00, imageUrl = "nui://qb-inventory/html/images/cake_chocolate.png", category = "desserts" },
                { id = "blueberry_pie", name = "Blueberry Pie", price = 6.50, imageUrl = "nui://qb-inventory/html/images/blueberry_pie.png", category = "desserts" },
                { id = "brownies", name = "Brownies", price = 4.50, imageUrl = "nui://qb-inventory/html/images/brownies.png", category = "desserts" }
            },
            categories = {                                -- Category definitions (key = internal name, value = display name)
                pastries = "Pastries",                     -- pastries = internal category key, "Pastries" = display name
                coffee = "Coffee",                         -- coffee = internal category key, "Coffee" = display name
                desserts = "Desserts"                      -- desserts = internal category key, "Desserts" = display name
            }
        },
        ]]
    }
}