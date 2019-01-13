package sha256

import (
	"golang.org/x/sys/cpu"
)

var useAVX2 = cpu.X86.HasAVX2 && cpu.X86.HasBMI2
