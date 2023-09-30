package main

import (
	"fmt"
	"github.com/google/uuid"
	"log"
	"time"
)

func main() {
	log.Println(time.Now())
	fmt.Println(uuid.NewUUID())
}
