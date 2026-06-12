package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"strings"
	"time"
)

// Helper to write JSON errors
func writeError(w http.ResponseWriter, status int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(map[string]string{"error": message})
}

// Helper to write JSON success responses
func writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

// Login
func handleLogin(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	var user User
	err := db.QueryRow(`SELECT id, name, email, role, profile_image, is_verified, created_at 
		FROM users WHERE email = ? AND password = ?`, req.Email, req.Password).Scan(
		&user.ID, &user.Name, &user.Email, &user.Role, &user.ProfileImage, &user.IsVerified, &user.CreatedAt,
	)

	if err != nil {
		writeError(w, http.StatusUnauthorized, "Invalid email or password")
		return
	}

	writeJSON(w, http.StatusOK, AuthResponse{
		Token: "onetech-mock-jwt-token-123456",
		User:  user,
	})
}

// Register
func handleRegister(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	var req RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.Name == "" || req.Email == "" || req.Password == "" {
		writeError(w, http.StatusBadRequest, "Name, email, and password are required")
		return
	}

	// Insert user
	res, err := db.Exec(`INSERT INTO users (name, email, password, role, profile_image, is_verified, created_at)
		VALUES (?, ?, ?, ?, ?, ?, ?)`,
		req.Name, req.Email, req.Password, "Business Owner", "", 1, time.Now())
	if err != nil {
		if strings.Contains(err.Error(), "UNIQUE constraint failed") {
			writeError(w, http.StatusConflict, "Email is already registered")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	id, _ := res.LastInsertId()

	var user User
	err = db.QueryRow(`SELECT id, name, email, role, profile_image, is_verified, created_at 
		FROM users WHERE id = ?`, id).Scan(
		&user.ID, &user.Name, &user.Email, &user.Role, &user.ProfileImage, &user.IsVerified, &user.CreatedAt,
	)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to retrieve registered user")
		return
	}

	writeJSON(w, http.StatusCreated, AuthResponse{
		Token: "onetech-mock-jwt-token-123456",
		User:  user,
	})
}

// Forgot Password
func handleForgotPassword(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	var req ForgotPasswordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.EmailOrPhone == "" {
		writeError(w, http.StatusBadRequest, "Email or phone is required")
		return
	}

	// Check if user exists by email (simulate success regardless to prevent enumeration in production,
	// but check if email looks like the seeded database emails)
	var id int64
	_ = db.QueryRow("SELECT id FROM users WHERE email = ?", req.EmailOrPhone).Scan(&id)

	writeJSON(w, http.StatusOK, map[string]string{
		"message": "Password reset instructions have been sent to " + req.EmailOrPhone,
	})
}

// Profile
func handleProfile(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	var user User
	err := db.QueryRow(`SELECT id, name, email, role, profile_image, is_verified, created_at 
		FROM users WHERE id = 1`).Scan(
		&user.ID, &user.Name, &user.Email, &user.Role, &user.ProfileImage, &user.IsVerified, &user.CreatedAt,
	)

	if err != nil {
		writeError(w, http.StatusInternalServerError, "User not found")
		return
	}

	writeJSON(w, http.StatusOK, user)
}

// Stock
func handleStock(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query("SELECT id, name, category, in_stock, low_stock_threshold, price, cost, image_url, created_at FROM stock_items ORDER BY name ASC")
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		defer rows.Close()

		var items []StockItem
		for rows.Next() {
			var item StockItem
			err := rows.Scan(&item.ID, &item.Name, &item.Category, &item.InStock, &item.LowStockThreshold, &item.Price, &item.Cost, &item.ImageUrl, &item.CreatedAt)
			if err != nil {
				writeError(w, http.StatusInternalServerError, err.Error())
				return
			}
			items = append(items, item)
		}
		writeJSON(w, http.StatusOK, items)

	case http.MethodPost:
		var item StockItem
		if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
			writeError(w, http.StatusBadRequest, "Invalid request body")
			return
		}

		res, err := db.Exec(`INSERT INTO stock_items (name, category, in_stock, low_stock_threshold, price, cost, image_url, created_at)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
			item.Name, item.Category, item.InStock, item.LowStockThreshold, item.Price, item.Cost, item.ImageUrl, time.Now())
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}

		id, _ := res.LastInsertId()
		item.ID = id
		writeJSON(w, http.StatusCreated, item)

	default:
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
	}
}

// Sales
func handleSales(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query("SELECT id, item_name, quantity, price, total_amount, customer_name, date, created_at FROM sales ORDER BY date DESC")
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		defer rows.Close()

		var records []SaleRecord
		for rows.Next() {
			var s SaleRecord
			err := rows.Scan(&s.ID, &s.ItemName, &s.Quantity, &s.Price, &s.TotalAmount, &s.CustomerName, &s.Date, &s.CreatedAt)
			if err != nil {
				writeError(w, http.StatusInternalServerError, err.Error())
				return
			}
			records = append(records, s)
		}
		writeJSON(w, http.StatusOK, records)

	case http.MethodPost:
		var s SaleRecord
		if err := json.NewDecoder(r.Body).Decode(&s); err != nil {
			writeError(w, http.StatusBadRequest, "Invalid request body")
			return
		}

		s.TotalAmount = s.Price * float64(s.Quantity)
		s.Date = time.Now()

		tx, err := db.Begin()
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}

		// Deduct from stock if a item with the same name exists
		var currentStock int
		err = tx.QueryRow("SELECT in_stock FROM stock_items WHERE name = ?", s.ItemName).Scan(&currentStock)
		if err == nil {
			newStock := currentStock - s.Quantity
			if newStock < 0 {
				newStock = 0
			}
			_, err = tx.Exec("UPDATE stock_items SET in_stock = ? WHERE name = ?", newStock, s.ItemName)
			if err != nil {
				tx.Rollback()
				writeError(w, http.StatusInternalServerError, "Failed to update stock: "+err.Error())
				return
			}
		}

		res, err := tx.Exec(`INSERT INTO sales (item_name, quantity, price, total_amount, customer_name, date, created_at)
			VALUES (?, ?, ?, ?, ?, ?, ?)`,
			s.ItemName, s.Quantity, s.Price, s.TotalAmount, s.CustomerName, s.Date, time.Now())
		if err != nil {
			tx.Rollback()
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}

		id, _ := res.LastInsertId()
		s.ID = id

		tx.Commit()
		writeJSON(w, http.StatusCreated, s)

	default:
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
	}
}

// Expenses
func handleExpenses(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query("SELECT id, category, description, amount, date, created_at FROM expenses ORDER BY date DESC")
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		defer rows.Close()

		var records []ExpenseRecord
		for rows.Next() {
			var e ExpenseRecord
			err := rows.Scan(&e.ID, &e.Category, &e.Description, &e.Amount, &e.Date, &e.CreatedAt)
			if err != nil {
				writeError(w, http.StatusInternalServerError, err.Error())
				return
			}
			records = append(records, e)
		}
		writeJSON(w, http.StatusOK, records)

	case http.MethodPost:
		var e ExpenseRecord
		if err := json.NewDecoder(r.Body).Decode(&e); err != nil {
			writeError(w, http.StatusBadRequest, "Invalid request body")
			return
		}

		e.Date = time.Now()

		res, err := db.Exec(`INSERT INTO expenses (category, description, amount, date, created_at)
			VALUES (?, ?, ?, ?, ?)`,
			e.Category, e.Description, e.Amount, e.Date, time.Now())
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}

		id, _ := res.LastInsertId()
		e.ID = id
		writeJSON(w, http.StatusCreated, e)

	default:
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
	}
}

// Analytics (Dashboard summary numbers & charts)
type AnalyticsResponse struct {
	TotalProfit      float64            `json:"total_profit"`
	ProfitPercentage float64            `json:"profit_percentage"`
	SalesAmount      float64            `json:"sales_amount"`
	SalesPercentage  float64            `json:"sales_percentage"`
	ExpensesAmount   float64            `json:"expenses_amount"`
	ExpensePercentage float64           `json:"expense_percentage"`
	SalesHistory     []ChartPoint       `json:"sales_history"`
	ExpenseHistory   []ChartPoint       `json:"expense_history"`
	ExpensesBreakdown map[string]float64 `json:"expenses_breakdown"`
}

type ChartPoint struct {
	Label string  `json:"label"`
	Value float64 `json:"value"`
}

func handleAnalytics(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	// Calculate Sales Amount (this month vs last month)
	var thisMonthSales, lastMonthSales float64
	thisMonthStart := time.Date(time.Now().Year(), time.Now().Month(), 1, 0, 0, 0, 0, time.UTC)
	lastMonthStart := thisMonthStart.AddDate(0, -1, 0)
	lastMonthEnd := thisMonthStart.Add(-time.Nanosecond)

	db.QueryRow("SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE date >= ?", thisMonthStart).Scan(&thisMonthSales)
	db.QueryRow("SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE date >= ? AND date <= ?", lastMonthStart, lastMonthEnd).Scan(&lastMonthSales)

	// Calculate Expenses Amount
	var thisMonthExpenses, lastMonthExpenses float64
	db.QueryRow("SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE date >= ?", thisMonthStart).Scan(&thisMonthExpenses)
	db.QueryRow("SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE date >= ? AND date <= ?", lastMonthStart, lastMonthEnd).Scan(&lastMonthExpenses)

	// Fallback/mocking to match screens if empty
	if thisMonthSales == 0 {
		thisMonthSales = 2400000 // TZS 2.4M
	}
	if thisMonthExpenses == 0 {
		thisMonthExpenses = 1550000 // TZS 1.55M
	}

	totalProfit := thisMonthSales - thisMonthExpenses
	profitPercentage := 18.5
	salesPercentage := 16.2
	expensePercentage := -8.1

	// Expense Breakdown mapping
	breakdown := make(map[string]float64)
	rows, err := db.Query("SELECT category, SUM(amount) FROM expenses GROUP BY category")
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var cat string
			var sum float64
			if err := rows.Scan(&cat, &sum); err == nil {
				breakdown[cat] = sum
			}
		}
	}
	if len(breakdown) == 0 {
		// Mock breakdown if empty to display pie chart correctly
		breakdown["Transport"] = 434000
		breakdown["Rent"] = 310000
		breakdown["Salaries"] = 387500
		breakdown["Utilities"] = 155000
		breakdown["Others"] = 263500
	}

	// Sales History points (weekly/monthly)
	var salesHistory []ChartPoint
	for i := 4; i >= 0; i-- {
		date := time.Now().AddDate(0, 0, -i*6)
		var dailyVal float64
		// Fetch sum for that date
		db.QueryRow("SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE date(date) = date(?)", date).Scan(&dailyVal)
		if dailyVal == 0 {
			dailyVal = float64(100000 + randInt(0, 200000))
		}
		salesHistory = append(salesHistory, ChartPoint{
			Label: date.Format("02 Jan"),
			Value: dailyVal,
		})
	}

	// Expense History points
	var expHistory []ChartPoint
	for i := 4; i >= 0; i-- {
		date := time.Now().AddDate(0, 0, -i*6)
		var dailyVal float64
		db.QueryRow("SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE date(date) = date(?)", date).Scan(&dailyVal)
		if dailyVal == 0 {
			dailyVal = float64(50000 + randInt(0, 100000))
		}
		expHistory = append(expHistory, ChartPoint{
			Label: date.Format("02 Jan"),
			Value: dailyVal,
		})
	}

	writeJSON(w, http.StatusOK, AnalyticsResponse{
		TotalProfit:       totalProfit,
		ProfitPercentage:  profitPercentage,
		SalesAmount:       thisMonthSales,
		SalesPercentage:   salesPercentage,
		ExpensesAmount:    thisMonthExpenses,
		ExpensePercentage: expensePercentage,
		SalesHistory:      salesHistory,
		ExpenseHistory:    expHistory,
		ExpensesBreakdown: breakdown,
	})
}

// Chat Messages List
func handleMessages(w http.ResponseWriter, r *http.Request) {
	chatID := r.URL.Query().Get("chat_id")
	if chatID == "" {
		writeError(w, http.StatusBadRequest, "Missing chat_id parameter")
		return
	}

	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query("SELECT id, chat_id, sender, content, timestamp, read FROM messages WHERE chat_id = ? ORDER BY timestamp ASC", chatID)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		defer rows.Close()

		var messages []Message
		for rows.Next() {
			var m Message
			err := rows.Scan(&m.ID, &m.ChatID, &m.Sender, &m.Content, &m.Timestamp, &m.Read)
			if err != nil {
				writeError(w, http.StatusInternalServerError, err.Error())
				return
			}
			messages = append(messages, m)
		}
		writeJSON(w, http.StatusOK, messages)

	case http.MethodPost:
		var m Message
		if err := json.NewDecoder(r.Body).Decode(&m); err != nil {
			writeError(w, http.StatusBadRequest, "Invalid request body")
			return
		}

		m.ChatID = chatID
		m.Timestamp = time.Now()
		m.Read = true

		res, err := db.Exec(`INSERT INTO messages (chat_id, sender, content, timestamp, read)
			VALUES (?, ?, ?, ?, ?)`,
			m.ChatID, m.Sender, m.Content, m.Timestamp, 1)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}

		id, _ := res.LastInsertId()
		m.ID = id

		// Update chat room last message
		_, _ = db.Exec("UPDATE chat_rooms SET last_message = ?, time = ? WHERE id = ?", m.Content, "Just now", chatID)

		// Mock Auto-Reply after a short latency (simulate real customer/seller replying)
		go func(cid string) {
			time.Sleep(1500 * time.Millisecond)
			replyContent := "Thanks for reaching out! Let me check on that and get back to you shortly."
			if strings.Contains(strings.ToLower(m.Content), "available") || strings.Contains(strings.ToLower(m.Content), "stock") {
				replyContent = "Yes! It is available in stock. You can place your order."
			} else if strings.Contains(strings.ToLower(m.Content), "delivery") || strings.Contains(strings.ToLower(m.Content), "ship") {
				replyContent = "We deliver across Dar es Salaam, Arusha and Mwanza. Standard delivery takes 1 day."
			}

			var name string
			_ = db.QueryRow("SELECT name FROM chat_rooms WHERE id = ?", cid).Scan(&name)

			_, _ = db.Exec(`INSERT INTO messages (chat_id, sender, content, timestamp, read)
				VALUES (?, ?, ?, ?, ?)`, cid, name, replyContent, time.Now(), 0)
			_, _ = db.Exec("UPDATE chat_rooms SET last_message = ?, time = ? WHERE id = ?", replyContent, "Just now", cid)
		}(chatID)

		writeJSON(w, http.StatusCreated, m)

	default:
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
	}
}

// Chat Rooms List
func handleChatRooms(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	rows, err := db.Query("SELECT id, name, last_message, time, image_url, active FROM chat_rooms")
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	defer rows.Close()

	var rooms []ChatRoom
	for rows.Next() {
		var rm ChatRoom
		var actVal int
		err := rows.Scan(&rm.ID, &rm.Name, &rm.LastMessage, &rm.Time, &rm.ImageUrl, &actVal)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		rm.Active = actVal == 1
		rooms = append(rooms, rm)
	}

	writeJSON(w, http.StatusOK, rooms)
}

// Financial Education Lessons
func handleLessons(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	rows, err := db.Query("SELECT id, title, category, duration, level, description, content, image_url FROM lessons")
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	defer rows.Close()

	var lessons []Lesson
	for rows.Next() {
		var l Lesson
		err := rows.Scan(&l.ID, &l.Title, &l.Category, &l.Duration, &l.Level, &l.Description, &l.Content, &l.ImageUrl)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		lessons = append(lessons, l)
	}

	writeJSON(w, http.StatusOK, lessons)
}

// Investments Opportunities Catalog
func handleInvestments(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	rows, err := db.Query("SELECT id, title, category, return_rate, min_investment, maturity_years, description, image_url, risk_level FROM investments")
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	defer rows.Close()

	var investments []Investment
	for rows.Next() {
		var i Investment
		err := rows.Scan(&i.ID, &i.Title, &i.Category, &i.ReturnRate, &i.MinInvestment, &i.MaturityYears, &i.Description, &i.ImageUrl, &i.RiskLevel)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		investments = append(investments, i)
	}

	writeJSON(w, http.StatusOK, investments)
}

// User Investments Portfolio
func handleUserInvestments(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query("SELECT id, user_id, investment_id, title, amount_invested, return_rate, expected_return, maturity_date, date_invested FROM user_investments WHERE user_id = 1")
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		defer rows.Close()

		var portfolio []UserInvestment
		for rows.Next() {
			var ui UserInvestment
			err := rows.Scan(&ui.ID, &ui.UserID, &ui.InvestmentID, &ui.Title, &ui.AmountInvested, &ui.ReturnRate, &ui.ExpectedReturn, &ui.MaturityDate, &ui.DateInvested)
			if err != nil {
				writeError(w, http.StatusInternalServerError, err.Error())
				return
			}
			portfolio = append(portfolio, ui)
		}
		writeJSON(w, http.StatusOK, portfolio)

	case http.MethodPost:
		var req struct {
			InvestmentID int64   `json:"investment_id"`
			Amount       float64 `json:"amount"`
		}

		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeError(w, http.StatusBadRequest, "Invalid request body")
			return
		}

		// Find investment details
		var inv Investment
		err := db.QueryRow("SELECT title, return_rate, maturity_years FROM investments WHERE id = ?", req.InvestmentID).Scan(&inv.Title, &inv.ReturnRate, &inv.MaturityYears)
		if err != nil {
			writeError(w, http.StatusNotFound, "Investment not found")
			return
		}

		expectedReturn := req.Amount * (inv.ReturnRate / 100.0) * float64(inv.MaturityYears)
		maturityDate := time.Now().AddDate(inv.MaturityYears, 0, 0)

		res, err := db.Exec(`INSERT INTO user_investments (user_id, investment_id, title, amount_invested, return_rate, expected_return, maturity_date, date_invested)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
			1, req.InvestmentID, inv.Title, req.Amount, inv.ReturnRate, expectedReturn, maturityDate, time.Now())
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}

		id, _ := res.LastInsertId()
		writeJSON(w, http.StatusCreated, map[string]interface{}{
			"id":              id,
			"title":           inv.Title,
			"amount_invested": req.Amount,
			"expected_return": expectedReturn,
			"maturity_date":   maturityDate,
		})

	default:
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
	}
}

// AI Advisor Cards generator (dynamic backend insights)
func handleAdvisorCards(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	var cards []AdvisorCard

	// Card 1: Profit Performance (Insight)
	cards = append(cards, AdvisorCard{
		ID:          "profit_insight",
		Title:       "Business Insight",
		Description: "Your profit increased by 18.5% compared to last month. Great job!",
		Type:        "insight",
	})

	// Card 2: Expense audit recommendation (Recommendation)
	// Check actual transport cost or other costs
	var transportCost float64
	db.QueryRow("SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE category = 'Transport'").Scan(&transportCost)
	recDesc := "Consider reducing transport expenses. They increased by 30% recently."
	if transportCost > 0 {
		recDesc = fmt.Sprintf("Transport costs represent %.0f%% of this month's expenses. Consider consolidation to reduce transit costs.", (transportCost/1550000.0)*100)
	}

	cards = append(cards, AdvisorCard{
		ID:          "expense_recommendation",
		Title:       "Recommendation",
		Description: recDesc,
		Type:        "recommendation",
	})

	// Card 3: Investment Suggestion (Suggestion)
	var cashAmount float64
	// Simple rule: if we have cash, suggest treasury bonds
	db.QueryRow("SELECT COALESCE(SUM(total_amount), 0) FROM sales").Scan(&cashAmount)
	sugDesc := "You have extra cash. I recommend investing in Treasury Bonds."
	if cashAmount > 0 {
		sugDesc = fmt.Sprintf("With TZS %.0f in sales surplus, consider investing TZS 100,000 in government bonds to earn 12.5%% p.a. guaranteed return.", cashAmount*0.1)
	}

	cards = append(cards, AdvisorCard{
		ID:          "investment_suggestion",
		Title:       "Investment Suggestion",
		Description: sugDesc,
		Type:        "suggestion",
	})

	writeJSON(w, http.StatusOK, cards)
}

// AI Chatbot responder
func handleAIChat(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	var req struct {
		Message string `json:"message"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	// Dynamic stats search to power AI responses
	var salesCount, lowStockCount int
	db.QueryRow("SELECT COUNT(*) FROM sales").Scan(&salesCount)
	db.QueryRow("SELECT COUNT(*) FROM stock_items WHERE in_stock <= low_stock_threshold").Scan(&lowStockCount)

	userMsg := strings.ToLower(req.Message)
	var reply string

	if strings.Contains(userMsg, "profit") || strings.Contains(userMsg, "financial") {
		reply = "Based on our records, your business is highly healthy this month, tracking a total profit of TZS 850,000. This is an 18.5% increase compared to last month. Your profit margins are strongest in the Food category."
	} else if strings.Contains(userMsg, "stock") || strings.Contains(userMsg, "inventory") {
		if lowStockCount > 0 {
			reply = fmt.Sprintf("You currently have %d items running low on stock. Specifically, Wheat Flour 2kg has only 3 bags left (threshold is 5). I suggest creating a purchase order today to avoid stockouts.", lowStockCount)
		} else {
			reply = "Your stock levels look optimal! No item is currently below its low stock threshold. Keep monitoring items daily."
		}
	} else if strings.Contains(userMsg, "expense") || strings.Contains(userMsg, "spend") {
		reply = "Your major expenses this month are Transport (28% of total spend) and Salaries (25%). If you want to optimize cash flow, consider optimizing your logistics routes or renegotiating supplier delivery rates."
	} else if strings.Contains(userMsg, "invest") || strings.Contains(userMsg, "grow") {
		reply = "I recommend taking a look at Government Treasury Bonds. The 2027 bond offers a low-risk 12.5% return annually. With your current profit surplus, you can easily invest the TZS 100,000 minimum without hurting operational liquidity."
	} else if strings.Contains(userMsg, "sale") {
		reply = fmt.Sprintf("We have recorded a total of %d sales transactions recently. Today's top-performing sales came from John Customer purchasing Rice (TZS 240,000). Weekly sales are trending up by 15.3%%.", salesCount)
	} else {
		reply = "I can analyze your business data! Try asking about: 'How is my profit?', 'Which products are running low in stock?', 'What are my main expenses?', or 'What should I invest in?'"
	}

	writeJSON(w, http.StatusOK, map[string]string{
		"reply": reply,
	})
}

// Utility random generator helper
func randInt(min, max int) int {
	return min + rand.Intn(max-min)
}

// Businesses Handlers
func handleBusinesses(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		var b Business
		err := db.QueryRow(`SELECT business_id, user_id, business_name, logo, description, verified 
			FROM businesses WHERE user_id = 1`).Scan(
			&b.BusinessID, &b.UserID, &b.BusinessName, &b.Logo, &b.Description, &b.Verified,
		)
		if err == sql.ErrNoRows {
			writeJSON(w, http.StatusOK, nil)
			return
		} else if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		writeJSON(w, http.StatusOK, b)
	case http.MethodPost:
		var b Business
		if err := json.NewDecoder(r.Body).Decode(&b); err != nil {
			writeError(w, http.StatusBadRequest, "Invalid request body")
			return
		}
		b.UserID = 1 // Default to user 1
		res, err := db.Exec(`INSERT INTO businesses (user_id, business_name, logo, description, verified) 
			VALUES (?, ?, ?, ?, ?)`, b.UserID, b.BusinessName, b.Logo, b.Description, 1)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		id, _ := res.LastInsertId()
		b.BusinessID = id
		b.Verified = true
		writeJSON(w, http.StatusCreated, b)
	default:
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
	}
}

// Products Handlers
func handleProducts(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query(`SELECT product_id, business_id, name, price, stock, category, description, images, video, featured, promoted, status 
			FROM products WHERE business_id = 1 ORDER BY product_id DESC`)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		defer rows.Close()

		var products []Product
		for rows.Next() {
			var p Product
			var featuredInt, promotedInt int
			err := rows.Scan(
				&p.ProductID, &p.BusinessID, &p.Name, &p.Price, &p.Stock, &p.Category,
				&p.Description, &p.Images, &p.Video, &featuredInt, &promotedInt, &p.Status,
			)
			if err != nil {
				writeError(w, http.StatusInternalServerError, err.Error())
				return
			}
			p.Featured = featuredInt != 0
			p.Promoted = promotedInt != 0
			products = append(products, p)
		}
		writeJSON(w, http.StatusOK, products)
	case http.MethodPost:
		var p Product
		if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
			writeError(w, http.StatusBadRequest, "Invalid request body")
			return
		}
		p.BusinessID = 1 // Default to business 1
		p.Status = "Active"

		featuredInt := 0
		if p.Featured {
			featuredInt = 1
		}
		promotedInt := 0
		if p.Promoted {
			promotedInt = 1
		}

		res, err := db.Exec(`INSERT INTO products (business_id, name, price, stock, category, description, images, video, featured, promoted, status) 
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			p.BusinessID, p.Name, p.Price, p.Stock, p.Category, p.Description, p.Images, p.Video, featuredInt, promotedInt, p.Status)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		id, _ := res.LastInsertId()
		p.ProductID = id

		// Automatically list in marketplace
		_, err = db.Exec(`INSERT INTO marketplace (product_id, ranking_score, views, likes, sales) 
			VALUES (?, ?, ?, ?, ?)`, p.ProductID, 5.0, 0, 0, 0)
		if err != nil {
			log.Printf("Failed to insert marketplace entry: %v", err)
		}

		writeJSON(w, http.StatusCreated, p)
	default:
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
	}
}

// Marketplace Handlers
func handleMarketplace(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	rows, err := db.Query(`
		SELECT m.listing_id, m.product_id, m.ranking_score, m.views, m.likes, m.sales,
		       p.product_id, p.business_id, p.name, p.price, p.stock, p.category, p.description, p.images, p.video, p.featured, p.promoted, p.status,
		       b.business_id, b.user_id, b.business_name, b.logo, b.description, b.verified
		FROM marketplace m
		INNER JOIN products p ON m.product_id = p.product_id
		INNER JOIN businesses b ON p.business_id = b.business_id
		ORDER BY m.ranking_score DESC
	`)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	defer rows.Close()

	var items []MarketplaceItem
	for rows.Next() {
		var item MarketplaceItem
		var pFeaturedInt, pPromotedInt, bVerifiedInt int
		err := rows.Scan(
			&item.ListingID, &item.ProductID, &item.RankingScore, &item.Views, &item.Likes, &item.Sales,
			&item.Product.ProductID, &item.Product.BusinessID, &item.Product.Name, &item.Product.Price, &item.Product.Stock, &item.Product.Category, &item.Product.Description, &item.Product.Images, &item.Product.Video, &pFeaturedInt, &pPromotedInt, &item.Product.Status,
			&item.Business.BusinessID, &item.Business.UserID, &item.Business.BusinessName, &item.Business.Logo, &item.Business.Description, &bVerifiedInt,
		)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		item.Product.Featured = pFeaturedInt != 0
		item.Product.Promoted = pPromotedInt != 0
		item.Business.Verified = bVerifiedInt != 0
		items = append(items, item)
	}

	writeJSON(w, http.StatusOK, items)
}

// Marketplace interaction
func handleMarketplaceInteract(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	var req struct {
		ListingID int64  `json:"listing_id"`
		Action    string `json:"action"` // "view", "like", "sale"
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	var query string
	switch req.Action {
	case "view":
		query = "UPDATE marketplace SET views = views + 1 WHERE listing_id = ?"
	case "like":
		query = "UPDATE marketplace SET likes = likes + 1, ranking_score = MIN(5.0, ranking_score + 0.01) WHERE listing_id = ?"
	case "sale":
		query = "UPDATE marketplace SET sales = sales + 1, ranking_score = MIN(5.0, ranking_score + 0.05) WHERE listing_id = ?"
	default:
		writeError(w, http.StatusBadRequest, "Invalid interaction action")
		return
	}

	_, err := db.Exec(query, req.ListingID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "success"})
}
