package main

import (
	"database/sql"
	"fmt"
	"log"
	"math/rand"
	"time"

	_ "modernc.org/sqlite"
)

var db *sql.DB

func initDB() {
	var err error
	db, err = sql.Open("sqlite", "./onetech.db")
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}

	// Create tables
	queries := []string{
		`CREATE TABLE IF NOT EXISTS users (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT,
			email TEXT UNIQUE,
			password TEXT,
			role TEXT,
			profile_image TEXT,
			is_verified INTEGER,
			created_at DATETIME
		);`,
		`CREATE TABLE IF NOT EXISTS stock_items (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT,
			category TEXT,
			in_stock INTEGER,
			low_stock_threshold INTEGER,
			price REAL,
			cost REAL,
			image_url TEXT,
			created_at DATETIME
		);`,
		`CREATE TABLE IF NOT EXISTS sales (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			item_name TEXT,
			quantity INTEGER,
			price REAL,
			total_amount REAL,
			customer_name TEXT,
			date DATETIME,
			created_at DATETIME
		);`,
		`CREATE TABLE IF NOT EXISTS expenses (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			category TEXT,
			description TEXT,
			amount REAL,
			date DATETIME,
			created_at DATETIME
		);`,
		`CREATE TABLE IF NOT EXISTS chat_rooms (
			id TEXT PRIMARY KEY,
			name TEXT,
			last_message TEXT,
			time TEXT,
			image_url TEXT,
			active INTEGER
		);`,
		`CREATE TABLE IF NOT EXISTS messages (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			chat_id TEXT,
			sender TEXT,
			content TEXT,
			timestamp DATETIME,
			read INTEGER
		);`,
		`CREATE TABLE IF NOT EXISTS lessons (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			title TEXT,
			category TEXT,
			duration TEXT,
			level TEXT,
			description TEXT,
			content TEXT,
			image_url TEXT
		);`,
		`CREATE TABLE IF NOT EXISTS investments (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			title TEXT,
			category TEXT,
			return_rate REAL,
			min_investment REAL,
			maturity_years INTEGER,
			description TEXT,
			image_url TEXT,
			risk_level TEXT
		);`,
		`CREATE TABLE IF NOT EXISTS user_investments (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			user_id INTEGER,
			investment_id INTEGER,
			title TEXT,
			amount_invested REAL,
			return_rate REAL,
			expected_return REAL,
			maturity_date DATETIME,
			date_invested DATETIME
		);`,
	}

	for _, q := range queries {
		if _, err := db.Exec(q); err != nil {
			log.Fatalf("Error executing query %q: %v", q, err)
		}
	}

	seedData()
}

func seedData() {
	// Seed user
	var count int
	err := db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		log.Fatalf("Failed to check user count: %v", err)
	}

	if count == 0 {
		_, err = db.Exec(`INSERT INTO users (name, email, password, role, profile_image, is_verified, created_at)
			VALUES (?, ?, ?, ?, ?, ?, ?)`,
			"John M. Doe", "john@onetech.com", "password", "Business Owner", "", 1, time.Now())
		if err != nil {
			log.Fatalf("Failed to seed user: %v", err)
		}
	}

	// Seed Stock Items
	err = db.QueryRow("SELECT COUNT(*) FROM stock_items").Scan(&count)
	if err != nil {
		log.Fatalf("Failed to check stock count: %v", err)
	}

	if count == 0 {
		items := []StockItem{
			{Name: "Rice 10kg", Category: "Food", InStock: 50, LowStockThreshold: 10, Price: 120000, Cost: 95000},
			{Name: "Sugar 5kg", Category: "Food", InStock: 35, LowStockThreshold: 10, Price: 80000, Cost: 65000},
			{Name: "Cooking Oil 1L", Category: "Food", InStock: 20, LowStockThreshold: 5, Price: 45000, Cost: 35000},
			{Name: "Wheat Flour 2kg", Category: "Food", InStock: 3, LowStockThreshold: 5, Price: 60000, Cost: 48000}, // Low Stock Alert
			{Name: "Salt 1kg", Category: "Food", InStock: 70, LowStockThreshold: 15, Price: 10000, Cost: 7500},
		}

		for _, item := range items {
			_, err = db.Exec(`INSERT INTO stock_items (name, category, in_stock, low_stock_threshold, price, cost, image_url, created_at)
				VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
				item.Name, item.Category, item.InStock, item.LowStockThreshold, item.Price, item.Cost, "", time.Now())
			if err != nil {
				log.Fatalf("Failed to seed stock item %s: %v", item.Name, err)
			}
		}
	}

	// Seed Sales
	err = db.QueryRow("SELECT COUNT(*) FROM sales").Scan(&count)
	if err != nil {
		log.Fatalf("Failed to check sales count: %v", err)
	}

	if count == 0 {
		// Insert today's sales
		todaySales := []SaleRecord{
			{ItemName: "Rice 10kg", Quantity: 2, Price: 120000, TotalAmount: 240000, CustomerName: "John Customer", Date: time.Now().Add(-5 * time.Hour)},
			{ItemName: "Sugar 5kg", Quantity: 1, Price: 80000, TotalAmount: 80000, CustomerName: "Mary Customer", Date: time.Now().Add(-3 * time.Hour)},
			{ItemName: "Cooking Oil 1L", Quantity: 1, Price: 45000, TotalAmount: 45000, CustomerName: "David Customer", Date: time.Now().Add(-1 * time.Hour)},
		}

		for _, s := range todaySales {
			_, err = db.Exec(`INSERT INTO sales (item_name, quantity, price, total_amount, customer_name, date, created_at)
				VALUES (?, ?, ?, ?, ?, ?, ?)`,
				s.ItemName, s.Quantity, s.Price, s.TotalAmount, s.CustomerName, s.Date, time.Now())
			if err != nil {
				log.Fatalf("Failed to seed sale: %v", err)
			}
		}

		// Insert past sales for a nice graph (last 30 days)
		rand.Seed(time.Now().UnixNano())
		for i := 1; i <= 30; i++ {
			date := time.Now().AddDate(0, 0, -i)
			numSales := rand.Intn(3) + 1 // 1 to 3 sales per day
			for j := 0; j < numSales; j++ {
				qty := rand.Intn(2) + 1
				price := float64((rand.Intn(5) + 1) * 20000)
				total := price * float64(qty)
				itemName := fmt.Sprintf("Mock Product %d", rand.Intn(5)+1)
				_, err = db.Exec(`INSERT INTO sales (item_name, quantity, price, total_amount, customer_name, date, created_at)
					VALUES (?, ?, ?, ?, ?, ?, ?)`,
					itemName, qty, price, total, fmt.Sprintf("Customer %d", i*10+j), date, time.Now())
				if err != nil {
					log.Fatalf("Failed to seed past sale: %v", err)
				}
			}
		}
	}

	// Seed Expenses
	err = db.QueryRow("SELECT COUNT(*) FROM expenses").Scan(&count)
	if err != nil {
		log.Fatalf("Failed to check expenses count: %v", err)
	}

	if count == 0 {
		// Match mockup expense data: Total: TZS 1,550,000
		// Transport 28% -> 434,000
		// Rent 20% -> 310,000
		// Salaries 25% -> 387,500
		// Utilities 10% -> 155,000
		// Others 17% -> 263,500
		expenses := []ExpenseRecord{
			{Category: "Transport", Description: "Delivery fuel and transit", Amount: 434000, Date: time.Now().AddDate(0, 0, -5)},
			{Category: "Rent", Description: "Shop space monthly rent", Amount: 310000, Date: time.Now().AddDate(0, 0, -10)},
			{Category: "Salaries", Description: "Sales assistant salary", Amount: 387500, Date: time.Now().AddDate(0, 0, -1)},
			{Category: "Utilities", Description: "Electricity and internet", Amount: 155000, Date: time.Now().AddDate(0, 0, -12)},
			{Category: "Others", Description: "Packaging materials and miscellaneous", Amount: 263500, Date: time.Now().AddDate(0, 0, -2)},
		}

		for _, exp := range expenses {
			_, err = db.Exec(`INSERT INTO expenses (category, description, amount, date, created_at)
				VALUES (?, ?, ?, ?, ?)`,
				exp.Category, exp.Description, exp.Amount, exp.Date, time.Now())
			if err != nil {
				log.Fatalf("Failed to seed expense: %v", err)
			}
		}

		// Seed past expenses for graph
		for i := 1; i <= 4; i++ {
			date := time.Now().AddDate(0, 0, -i*7)
			categories := []string{"Transport", "Utilities", "Others"}
			for _, cat := range categories {
				amount := float64((rand.Intn(10) + 5) * 10000)
				_, err = db.Exec(`INSERT INTO expenses (category, description, amount, date, created_at)
					VALUES (?, ?, ?, ?, ?)`,
					cat, "Weekly operational expense", amount, date, time.Now())
				if err != nil {
					log.Fatalf("Failed to seed weekly expense: %v", err)
				}
			}
		}
	}

	// Seed Chat Rooms
	err = db.QueryRow("SELECT COUNT(*) FROM chat_rooms").Scan(&count)
	if err != nil {
		log.Fatalf("Failed to check chat rooms count: %v", err)
	}

	if count == 0 {
		rooms := []ChatRoom{
			{ID: "ella_shop", Name: "Ella Shop", LastMessage: "Hi, is the product still available?", Time: "2m ago", Active: true},
			{ID: "tech_world", Name: "Tech World", LastMessage: "We have delivery tomorrow", Time: "15m ago", Active: true},
			{ID: "john_customer", Name: "John Customer", LastMessage: "Thanks for your service", Time: "1h ago", Active: false},
			{ID: "agri_hub", Name: "Agri Hub", LastMessage: "Let me know if you need more", Time: "2h ago", Active: true},
			{ID: "fashion_store", Name: "Fashion Store", LastMessage: "Your order has been shipped", Time: "3h ago", Active: false},
		}

		for _, r := range rooms {
			_, err = db.Exec(`INSERT INTO chat_rooms (id, name, last_message, time, image_url, active)
				VALUES (?, ?, ?, ?, ?, ?)`,
				r.ID, r.Name, r.LastMessage, r.Time, r.ImageUrl, r.Active)
			if err != nil {
				log.Fatalf("Failed to seed chat room: %v", err)
			}

			// Add initial message for this room
			_, err = db.Exec(`INSERT INTO messages (chat_id, sender, content, timestamp, read)
				VALUES (?, ?, ?, ?, ?)`,
				r.ID, r.Name, r.LastMessage, time.Now().Add(-10 * time.Minute), 0)
			if err != nil {
				log.Fatalf("Failed to seed message: %v", err)
			}
		}
	}

	// Seed Lessons
	err = db.QueryRow("SELECT COUNT(*) FROM lessons").Scan(&count)
	if err != nil {
		log.Fatalf("Failed to check lessons count: %v", err)
	}

	if count == 0 {
		lessons := []Lesson{
			{Title: "How to Start a Business", Category: "Business", Duration: "12 lessons", Level: "Beginner", Description: "A comprehensive guide to starting a successful business from scratch.", Content: "## Welcome to Starting a Business\n\nStarting a business is a major step. It requires validation, building a solid team, identifying customer needs, and planning financial operations.\n\n### Key Pillars:\n1. **Value Proposition**: What makes you unique?\n2. **Market Analysis**: Who are your competitors?\n3. **Financial Plan**: How will you turn a profit?\n4. **Operations**: Setting up inventory and accounting systems."},
			{Title: "Understanding Cash Flow", Category: "Investing", Duration: "10 lessons", Level: "Beginner", Description: "Learn how cash moves in and out of your business and how to keep it positive.", Content: "## Cash Flow Basics\n\nCash flow is the lifeblood of business. It differs from profit. A profitable business can still go bankrupt if cash is tied up in inventory or unpaid customer bills.\n\n### Three Cash Flow Sections:\n- **Operating Cash**: Standard day-to-day business operations.\n- **Investing Cash**: Buying assets, capital equipment, or bonds.\n- **Financing Cash**: Money from loans, investments, or withdrawals."},
			{Title: "Investment for Beginners", Category: "Investing", Duration: "15 lessons", Level: "Intermediate", Description: "Grow your wealth by learning how to make money work for you.", Content: "## Investment Principles\n\nInvesting is the act of allocating resources, usually money, with the expectation of generating income or profit.\n\n### Asset Classes:\n- **Equities (Shares)**: Ownership in a company.\n- **Fixed Income (Bonds)**: Lending money to a corporation or government.\n- **Real Estate**: Tangible properties.\n- **Cryptocurrency**: Decentralized digital assets."},
			{Title: "How to Manage Debt", Category: "Saving", Duration: "8 lessons", Level: "Beginner", Description: "Strategies to handle personal and business debt effectively.", Content: "## Managing and Paying Off Debt\n\nDebt can be a tool or a trap. Business loans can expand operations, but high interest can cripple growth.\n\n### Debt Management Methods:\n1. **Snowball Method**: Pay off smallest debts first.\n2. **Avalanche Method**: Pay off highest interest rate debts first.\n3. **Refinancing**: Consolidating debt into lower rates."},
		}

		for _, l := range lessons {
			_, err = db.Exec(`INSERT INTO lessons (title, category, duration, level, description, content, image_url)
				VALUES (?, ?, ?, ?, ?, ?, ?)`,
				l.Title, l.Category, l.Duration, l.Level, l.Description, l.Content, "")
			if err != nil {
				log.Fatalf("Failed to seed lesson: %v", err)
			}
		}
	}

	// Seed Investments
	err = db.QueryRow("SELECT COUNT(*) FROM investments").Scan(&count)
	if err != nil {
		log.Fatalf("Failed to check investments count: %v", err)
	}

	if count == 0 {
		invests := []Investment{
			{Title: "Treasury Bond 2027", Category: "Bonds", ReturnRate: 12.5, MinInvestment: 100000, MaturityYears: 2, Description: "Government bond with fixed returns and low risk. Ideal for capital preservation.", RiskLevel: "Low"},
			{Title: "OneTech Retail Shares", Category: "Shares", ReturnRate: 15.2, MinInvestment: 500000, MaturityYears: 5, Description: "Equity shares in emerging retail businesses with high growth potential.", RiskLevel: "Medium"},
			{Title: "Real Estate REIT Fund", Category: "Real Estate", ReturnRate: 8.5, MinInvestment: 1000000, MaturityYears: 4, Description: "Dividends paid quarterly from premium commercial real estate holdings.", RiskLevel: "Low"},
			{Title: "Agri-Grow Cassava Farms", Category: "Agriculture", ReturnRate: 18.0, MinInvestment: 250000, MaturityYears: 1, Description: "Direct support to local farmers in Morogoro, sharing harvest profit yields.", RiskLevel: "High"},
			{Title: "OneTech Crypto Index", Category: "Cryptocurrency", ReturnRate: 45.0, MinInvestment: 50000, MaturityYears: 3, Description: "Diversified index tracking top 10 utility tokens. High risk, high reward.", RiskLevel: "High"},
		}

		for _, inv := range invests {
			_, err = db.Exec(`INSERT INTO investments (title, category, return_rate, min_investment, maturity_years, description, image_url, risk_level)
				VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
				inv.Title, inv.Category, inv.ReturnRate, inv.MinInvestment, inv.MaturityYears, inv.Description, "", inv.RiskLevel)
			if err != nil {
				log.Fatalf("Failed to seed investment: %v", err)
			}
		}

		// Seed a default active investment for the user
		_, err = db.Exec(`INSERT INTO user_investments (user_id, investment_id, title, amount_invested, return_rate, expected_return, maturity_date, date_invested)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
			1, 1, "Treasury Bond 2027", 5250000, 12.5, 656250, time.Now().AddDate(2, 0, 0), time.Now().AddDate(-1, 0, 0))
		if err != nil {
			log.Fatalf("Failed to seed user investment: %v", err)
		}
	}
}
