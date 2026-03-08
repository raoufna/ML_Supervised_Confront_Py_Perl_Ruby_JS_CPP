TARGET := main.exe
SRC := main.cpp globals.cpp
LIBS_NAME := armadillo

CXX := g++
CXXFLAGS += -std=c++17 -Wall -Wextra -O3 -DNDEBUG -fopenmp

# --- PERCORSI MSYS2 ---
# Dato che hai detto di usare MINGW64, il percorso base è questo.
# NOTA: se ricevi ancora errore, cambia "mingw64" in "ucrt64" (visto che il tuo g++ era lì).
MSYS_BASE := C:/msys64/ucrt64

# MSYS2 ha già tutto dentro le sue cartelle standard include e lib
LDFLAGS   := -fopenmp -L"$(MSYS_BASE)/lib"
INCLFLAGS := -I. -I"$(MSYS_BASE)/include"

CXXFLAGS  += $(INCLFLAGS)
OBJS := $(SRC:.cpp=.o)
LIBS := $(addprefix -l,$(LIBS_NAME))
CLEAN_LIST := $(TARGET) $(OBJS)

default: all

$(TARGET): $(OBJS)
	$(CXX) $(OBJS) -o $(TARGET) $(LDFLAGS) $(LIBS)


.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	@echo CLEAN $(CLEAN_LIST)
	@rm -f $(CLEAN_LIST)