package timeserver

import (
	"context"

	timev1 "github.com/ardfard/go-web-skeleton/api/grpc/gen/time/v1"
	"github.com/ardfard/go-web-skeleton/internal/time"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var (
	_ timev1.TimeServer = (*TimeServer)(nil)
)

type TimeServer struct {
	timev1.UnimplementedTimeServer
}

func (ts TimeServer) GetNowRequest(ctx context.Context, _ *timev1.GetNowRequest) (*timev1.GetNowResponse, error) {

	now, _ := time.GetCurrent()
	return &timev1.GetNowResponse{Now: timestamppb.New(now)}, nil
}
