# Game
SOURCES=${wildcard *.cpp}
OBJECTS=$(SOURCES:.cpp=$(OBJ_EXTENSION))

.SUFFIXES: .cpp .o .obj

# Rules
.cpp$(OBJ_EXTENSION):
	$(CC) $(GEN_OBJECT_FLAG) $< $(OBJ_OUTPUT_FLAG) $@ $(CFLAGS) $(INCLUDES)

# Build the game
all: $(COMPONENTS) $(GAME)

$(COMPONENTS):
	$(MAKE) -C $@ 

$(GAME): $(COMPONENTS) $(OBJECTS)
	$(LINKER) $(OUTPUT_FLAG)$@ $(OBJECTS) $(LDFLAGS) $(LIBS) $(EXTRA_LIBS)

.PHONY: all $(COMPONENTS)
