package middleware

import (
	"net"
	"net/http"
	"sync"
	"time"
)

// RateLimit returns middleware that limits each IP to maxReqs per window.
// Uses a simple in-memory token bucket — suitable for a low-traffic proxy.
func RateLimit(maxReqs int, window time.Duration) func(http.Handler) http.Handler {
	type bucket struct {
		count    int
		resetAt  time.Time
	}

	var mu sync.Mutex
	buckets := make(map[string]*bucket)

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ip, _, err := net.SplitHostPort(r.RemoteAddr)
			if err != nil {
				ip = r.RemoteAddr
			}

			mu.Lock()
			b, ok := buckets[ip]
			now := time.Now()
			if !ok || now.After(b.resetAt) {
				b = &bucket{resetAt: now.Add(window)}
				buckets[ip] = b
			}
			b.count++
			over := b.count > maxReqs
			mu.Unlock()

			if over {
				http.Error(w, `{"error":"rate limit exceeded"}`, http.StatusTooManyRequests)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
