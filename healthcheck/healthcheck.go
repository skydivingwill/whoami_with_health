package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	_, err := http.Get(fmt.Sprintf("http://127.0.0.1:%s/health", os.Getenv("HEALTH_PORT_NUMBER")))
	if err != nil {
		os.Exit(1)
	}
}
