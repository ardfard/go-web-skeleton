package time

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetCurrent(t *testing.T) {
	assert.NotPanics(t, func() {
		_, _ = GetCurrent()
	})
}
