package main

import (
	"log"
	"net"

	timev1 "github.com/ardfard/go-web-skeleton/api/grpc/gen/time/v1"
	"github.com/ardfard/go-web-skeleton/api/grpc/timeserver"
	"github.com/labstack/echo-contrib/prometheus"
	"github.com/labstack/echo/v4"
	"google.golang.org/grpc"
)

func main() {
	grpcServer := grpc.NewServer()
	timev1.RegisterTimeServer(grpcServer, timeserver.TimeServer{})

	e := echo.New()
	p := prometheus.NewPrometheus("echo", nil)

	// Start http server
	go func(e *echo.Echo, p *prometheus.Prometheus) {
		p.Use(e)
		e.GET("/", func(c echo.Context) error {
			return c.String(200, "Hello, World!")
		})
		e.Logger.Fatal(e.Start(":1323"))
	}(e, p)

	// Start grpc server
	l, err := net.Listen("tcp", ":9093")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	log.Printf("starting grpc server at :9093")
	log.Fatal(grpcServer.Serve(l))
}
