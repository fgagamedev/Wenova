#Targets
NAME=game_$(PLATFORM)_$(MODE)
TARGET=$(STATIC_LIB_PREFIX)$(NAME)$(STATIC_LIB_EXTENSION)

# Files
SOURCES=${wildcard src/*.cpp}
SOURCES+=${wildcard src/$(PLATFORM)/*.cpp}

OBJECTS=$(SOURCES:.cpp=$(OBJ_EXTENSION))

.SUFFIXES: .cpp .o .obj

# Rules
.cpp$(OBJ_EXTENSION):
	$(CC) $(GEN_OBJECT_FLAG) $< $(CFLAGS) $(INCLUDES) $(OBJ_OUTPUT_FLAG)$@

all: $(TARGET)

# Targets
$(TARGET): $(OBJECTS)
	$(AR) $(AR_FLAGS) $(AR_OUTPUT_FLAG)$@ $(OBJECTS) 
