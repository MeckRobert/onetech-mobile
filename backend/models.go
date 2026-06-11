package main

import "time"

// User represents a user account
type User struct {
	ID           int64     `json:"id"`
	Name         string    `json:"name"`
	Email        string    `json:"email"`
	Password     string    `json:"-"`
	Role         string    `json:"role"`
	ProfileImage string    `json:"profile_image"`
	IsVerified   bool      `json:"is_verified"`
	CreatedAt    time.Time `json:"created_at"`
}

// StockItem represents an inventory item
type StockItem struct {
	ID                int64     `json:"id"`
	Name              string    `json:"name"`
	Category          string    `json:"category"`
	InStock           int       `json:"in_stock"`
	LowStockThreshold int       `json:"low_stock_threshold"`
	Price             float64   `json:"price"`
	Cost              float64   `json:"cost"`
	ImageUrl          string    `json:"image_url"`
	CreatedAt         time.Time `json:"created_at"`
}

// SaleRecord represents a completed sale
type SaleRecord struct {
	ID           int64     `json:"id"`
	ItemName     string    `json:"item_name"`
	Quantity     int       `json:"quantity"`
	Price        float64   `json:"price"`
	TotalAmount  float64   `json:"total_amount"`
	CustomerName string    `json:"customer_name"`
	Date         time.Time `json:"date"`
	CreatedAt    time.Time `json:"created_at"`
}

// ExpenseRecord represents a business expense
type ExpenseRecord struct {
	ID          int64     `json:"id"`
	Category    string    `json:"category"`
	Description string    `json:"description"`
	Amount      float64   `json:"amount"`
	Date        time.Time `json:"date"`
	CreatedAt   time.Time `json:"created_at"`
}

// ChatRoom represents a chat thread
type ChatRoom struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	LastMessage string    `json:"last_message"`
	Time        string    `json:"time"`
	ImageUrl    string    `json:"image_url"`
	Active      bool      `json:"active"`
}

// Message represents a chat message
type Message struct {
	ID        int64     `json:"id"`
	ChatID    string    `json:"chat_id"`
	Sender    string    `json:"sender"`
	Content   string    `json:"content"`
	Timestamp time.Time `json:"timestamp"`
	Read      bool      `json:"read"`
}

// Lesson represents a financial education class
type Lesson struct {
	ID          int64  `json:"id"`
	Title       string `json:"title"`
	Category    string `json:"category"`
	Duration    string `json:"duration"`
	Level       string `json:"level"`
	Description string `json:"description"`
	Content     string `json:"content"`
	ImageUrl    string `json:"image_url"`
}

// Investment represents a wealth building opportunity
type Investment struct {
	ID            int64   `json:"id"`
	Title         string  `json:"title"`
	Category      string  `json:"category"`
	ReturnRate    float64 `json:"return_rate"`
	MinInvestment float64 `json:"min_investment"`
	MaturityYears int     `json:"maturity_years"`
	Description   string  `json:"description"`
	ImageUrl      string  `json:"image_url"`
	RiskLevel     string  `json:"risk_level"`
}

// UserInvestment represents an investment purchased by a user
type UserInvestment struct {
	ID             int64     `json:"id"`
	UserID         int64     `json:"user_id"`
	InvestmentID   int64     `json:"investment_id"`
	Title          string    `json:"title"`
	AmountInvested float64   `json:"amount_invested"`
	ReturnRate     float64   `json:"return_rate"`
	ExpectedReturn float64   `json:"expected_return"`
	MaturityDate   time.Time `json:"maturity_date"`
	DateInvested   time.Time `json:"date_invested"`
}

// AdvisorCard represents an AI recommendation card
type AdvisorCard struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Type        string `json:"type"` // insight, recommendation, suggestion
}

// LoginRequest defines credentials payload
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// AuthResponse defines successful login output
type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}
