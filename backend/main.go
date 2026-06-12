package main

import (
	"log"
	"net/http"
	"os"
)

// CORSMiddleware adds CORS headers to all responses
func CORSMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func main() {
	// Initialize database
	initDB()
	defer db.Close()

	// Register router mux
	mux := http.NewServeMux()

	// Auth routes
	mux.HandleFunc("/api/login", handleLogin)
	mux.HandleFunc("/api/profile", handleProfile)

	// Business routes
	mux.HandleFunc("/api/stock", handleStock)
	mux.HandleFunc("/api/sales", handleSales)
	mux.HandleFunc("/api/expenses", handleExpenses)
	mux.HandleFunc("/api/analytics", handleAnalytics)

	// Growth routes
	mux.HandleFunc("/api/chat-rooms", handleChatRooms)
	mux.HandleFunc("/api/messages", handleMessages)
	mux.HandleFunc("/api/lessons", handleLessons)
	mux.HandleFunc("/api/investments", handleInvestments)
	mux.HandleFunc("/api/user-investments", handleUserInvestments)

	// AI routes
	mux.HandleFunc("/api/advisor-cards", handleAdvisorCards)
	mux.HandleFunc("/api/ai-chat", handleAIChat)

	// Apply CORS middleware
	handler := CORSMiddleware(mux)

	// Get Render port
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("ONETECH backend running on port %s", port)

	// Start server
	if err := http.ListenAndServe(":"+port, handler); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}