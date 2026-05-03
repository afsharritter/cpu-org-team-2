
# Makefile for main RSA program and RSALib tests

SRC   = src
TESTS = tests
BIN   = bin

all: $(BIN) $(BIN)/rsa $(BIN)/run_tests_RSALib

$(BIN):
	mkdir -p $(BIN)

# Main RSA program
$(BIN)/rsa: $(BIN)/RSA.o $(BIN)/RSALib.o
	gcc $(BIN)/RSA.o $(BIN)/RSALib.o -o $(BIN)/rsa

$(BIN)/RSA.o: $(SRC)/RSA.s
	gcc -c $(SRC)/RSA.s -o $(BIN)/RSA.o

$(BIN)/RSALib.o: $(SRC)/RSALib.s
	gcc -c $(SRC)/RSALib.s -o $(BIN)/RSALib.o

#Tests
$(BIN)/run_tests_RSALib: $(BIN)/test_RSALib.o $(BIN)/RSALib.o
	gcc $(BIN)/test_RSALib.o $(BIN)/RSALib.o -o $(BIN)/run_tests_RSALib

$(BIN)/test_RSALib.o: $(TESTS)/test_RSALib.s
	gcc -c $(TESTS)/test_RSALib.s -o $(BIN)/test_RSALib.o

clean:
	rm -rf $(BIN)/*
