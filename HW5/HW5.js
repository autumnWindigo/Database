// Problem 1
db.unemployment.aggregate([
    {
        $group:
        /**
         * Gather years
         */
        {
            _id: "$Year"
        }
    },
    {
        $count:
            /**
             * Count years
             */
            "numberOfYears"
    }
])

// Problem 2
db.unemployment.aggregate([
    {
        $group:
        /**
         * Gather states
         */
        {
            _id: "$State"
        }
    },
    {
        $count:
            /**
             * Count the states
             */
            "numberOfStates"
    }
])

// Problem 3
/*
It would compute the amount of documents in which the unemployment rate
is less than 1.0
*/

// Problem 4
db.unemployment.find({ // Find
    Rate: { $gt: 10.0 } // Unemployment Rate > 10.0
}).count() // Count to find num

// Problem 5
db.unemployment.aggregate([
    {
        $group:
        {
            _id: "$State", // Group by state
            Average: { // Find average rate
                $avg: "$Rate"
            }
        }
    }
])

// Problem 6
db.unemployment.find(
    { Rate: { $lt: 8.0, $gt: 5.0 } }, // Find rate between
    { _id: 0, County: 1 } // Only list counties that match
)

// Problem 7
db.unemployment.aggregate([
    {
        $group:
        /**
         * Group by state
         * Find highest rate in state
         */
        {
            _id: "$State",
            highestRate: {
                $max: "$Rate"
            }
        }
    },
    {
        $sort:
        /**
         * Sort in descending order (highest first)
         */
        {
            highestRate: -1
        }
    },
    {
        $limit:
            /* Only output highest */
            1
    }
])

// Problem 8
db.unemployment.find(
    { Rate: { $gt: 5.0 } }, // Only find rate > 5.0
    { _id: 0, County: 1 } // only list counties
).count()

// Problem 9
db.unemployment.aggregate([
    {
        $group:
        /**
         * Group by state and year
         * Find avg rate of groups
         */
        {
            _id: {
                State: "$State",
                Year: "$Year"
            },
            avgUnemploy: {
                $avg: "$Rate"
            }
        }
    }
])

// Problem 10
db.unemployment.aggregate([
    {
        $group:
        /**
         * Group by state
         * Combine all rates for the state
         */
        {
            _id: "$State",
            combinedRate: {
                $sum: "$Rate"
            }
        }
    }
])

// Problem 11
db.unemployment.aggregate([
    {
        $match:
        /**
         * Select only >= 2015
         */
        {
            Year: {
                $gte: 2015
            }
        }
    },
    {
        $group:
        /**
         * Group by selected states
         * Combine all rates for the state
         */
        {
            _id: "$State",
            combinedRate: {
                $sum: "$Rate"
            }
        }
    }
])
