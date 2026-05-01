
# Makefile for main RSA program and RSALib tests

SRC   = src
TESTS = tests
BIN   = bin

all: $(BIN) $(BIN)/rsa $(BIN)/run_tests_RSALib $(BIN)/run_tests_decrypt $(BIN)/run_tests_encrypt $(BIN)/run_tests_modinv $(BIN)/run_tests_cpubexp

# Main RSA program
$(BIN)/rsa: $(BIN)/RSA.o $(BIN)/RSALib.o $(BIN)/modinv.o
	gcc $(BIN)/RSA.o $(BIN)/RSALib.o $(BIN)/modinv.o -o $(BIN)/rsa

$(BIN)/RSA.o: $(SRC)/RSA.s
	gcc -c $(SRC)/RSA.s -o $(BIN)/RSA.o

$(BIN)/RSALib.o: $(SRC)/RSALib.s
	gcc -c $(SRC)/RSALib.s -o $(BIN)/RSALib.o

$(BIN)/modinv.o: $(SRC)/modinv.s
	gcc -c $(SRC)/modinv.s -o $(BIN)/modinv.o

#Tests
$(BIN)/run_tests_RSALib: $(BIN)/test_RSALib.o $(BIN)/RSALib.o
	gcc $(BIN)/test_RSALib.o $(BIN)/RSALib.o -o $(BIN)/run_tests_RSALib

$(BIN)/test_RSALib.o: $(TESTS)/test_RSALib.s
	gcc -c $(TESTS)/test_RSALib.s -o $(BIN)/test_RSALib.o

$(BIN)/run_tests_cpubexp: $(BIN)/test_cpubexp.o $(BIN)/cpubexp.o
	gcc $(BIN)/test_cpubexp.o $(BIN)/cpubexp.o -o $(BIN)/run_tests_cpubexp

$(BIN)/test_cpubexp.o: $(TESTS)/test_cpubexp.s
	gcc -c $(TESTS)/test_cpubexp.s -o $(BIN)/test_cpubexp.o

$(BIN)/run_tests_decrypt: $(BIN)/test_decrypt.o $(BIN)/RSALib.o
	gcc $(BIN)/test_decrypt.o $(BIN)/RSALib.o -o $(BIN)/run_tests_decrypt

$(BIN)/test_decrypt.o: $(TESTS)/test_decrypt.s
	gcc -c $(TESTS)/test_decrypt.s -o $(BIN)/test_decrypt.o

$(BIN)/run_tests_encrypt: $(BIN)/test_encrypt.o $(BIN)/RSALib.o
	gcc $(BIN)/test_encrypt.o $(BIN)/RSALib.o -o $(BIN)/run_tests_encrypt

$(BIN)/test_encrypt.o: $(TESTS)/test_encrypt.s
	gcc -c $(TESTS)/test_encrypt.s -o $(BIN)/test_encrypt.o

$(BIN)/run_tests_modinv: $(BIN)/test_modinv.o $(BIN)/modinv.o
	gcc $(BIN)/test_modinv.o $(BIN)/modinv.o -o $(BIN)/run_tests_modinv

$(BIN)/test_modinv.o: $(TESTS)/test_modinv.s
	gcc -c $(TESTS)/test_modinv.s -o $(BIN)/test_modinv.o

clean:
	rm -rf $(BIN)/*
