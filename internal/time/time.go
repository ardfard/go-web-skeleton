package time

import "time"

func GetCurrent() (time.Time, error) {
	return time.Now(), nil
}
