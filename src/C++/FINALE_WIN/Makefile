TARGET := main.exe
SRC := main.cpp globals.cpp
LIBS_NAME := armadillo

CXX := g++
CXXFLAGS += -std=c++17 -Wall -Wextra -O3 -DNDEBUG -fopenmp

# --- MSYS2 PATHS ---
#This is the part where the 2 makefile differ
MSYS_BASE := C:/msys64/ucrt64 

LDFLAGS   := -fopenmp -L"$(MSYS_BASE)/lib"
INCLFLAGS := -I. -I"$(MSYS_BASE)/include"

CXXFLAGS  += $(INCLFLAGS)
OBJS := $(SRC:.cpp=.o)
LIBS := $(addprefix -l,$(LIBS_NAME))
CLEAN_LIST := $(TARGET) $(OBJS)

# Default rule
default: all

$(TARGET): $(OBJS)
	$(CXX) $(OBJS) -o $(TARGET) $(LDFLAGS) $(LIBS)

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	@echo CLEAN $(CLEAN_LIST)
	@rm -f $(CLEAN_LIST)