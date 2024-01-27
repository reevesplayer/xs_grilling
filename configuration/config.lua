local seconds = 1000
Config = {}

Config.Progressbar = {
    type = 'circle' -- circle / bar
}

Config.BBQ = {

    ['small_bbq'] = {
        prop = 'small_bbq'.
        setupTime = 4 * seconds,
        pickupTime = 4 * seconds,

        recipes = {
            {
                label = 'Burger',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_burger'] = 1,
                },

                requirments = {
                    ['raw_burger'] = { label = 'Raw Burger', quantity = 1 },
                },
            },
            {
                label = 'Hotdog',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_hotdog'] = 1,
                },

                requirments = {
                    ['raw_hotdog'] = { label = 'Raw Hotdog', quantity = 1 },
                },
            },
            {
                label = 'Steak',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_steak'] = 1,
                },

                requirments = {
                    ['raw_steak'] = { label = 'Raw Steak', quantity = 1 },
                },
            },
            {
                label = 'Chicken',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_chicken'] = 1,
                },

                requirments = {
                    ['raw_chicken'] = { label = 'Raw Chicken', quantity = 1 },
                },
            },
            {
                label = 'Fish',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_fish'] = 1,
                },

                requirments = {
                    ['raw_fish'] = { label = 'Raw Fish', quantity = 1 },
                },
            },
        }
    }

    ['large_bbq'] = {
        prop = 'large_bbq'.
        setupTime = 4 * seconds,
        pickupTime = 4 * seconds,

        recipes = {
            {
                label = 'Burger',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_burger'] = 1,
                },

                requirments = {
                    ['raw_burger'] = { label = 'Raw Burger', quantity = 1 },
                },
            },
            {
                label = 'Hotdog',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_hotdog'] = 1,
                },

                requirments = {
                    ['raw_hotdog'] = { label = 'Raw Hotdog', quantity = 1 },
                },
            },
            {
                label = 'Steak',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_steak'] = 1,
                },

                requirments = {
                    ['raw_steak'] = { label = 'Raw Steak', quantity = 1 },
                },
            },
            {
                label = 'Chicken',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_chicken'] = 1,
                },

                requirments = {
                    ['raw_chicken'] = { label = 'Raw Chicken', quantity = 1 },
                },
            },
            {
                label = 'Fish',
                cookingTime = 12 * seconds,

                reward = {
                    ['cooked_fish'] = 1,
                },

                requirments = {
                    ['raw_fish'] = { label = 'Raw Fish', quantity = 1 },
                },
            },
        }
    }
}