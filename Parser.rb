# https://www.cs.rochester.edu/~brown/173/readings/05_grammars.txt
#
#  "TINY" Grammar
#
# PGM        -->   STMT+
# STMT       -->   ASSIGN   |   "print"  EXP
# ASSIGN     -->   ID  "="  EXP
# EXP        -->   TERM   ETAIL
# ETAIL      -->   "+" TERM   ETAIL  | "-" TERM   ETAIL | EPSILON
# TERM       -->   FACTOR  TTAIL
# TTAIL      -->   "*" FACTOR TTAIL  | "/" FACTOR TTAIL | EPSILON
# FACTOR     -->   "(" EXP ")" | INT | ID
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
load "Token.rb"
load "Lexer.rb"
class Parser < Scanner
	def initialize(filename)
    		super(filename)
    		consume()
   	end
   	
	def consume()
      		@lookahead = nextToken()
      		while(@lookahead.type == Token::WS)
        		@lookahead = nextToken()
      		end
   	end
  	
	def match(dtype, type)
      		if (@lookahead.type != dtype)
         		puts "Expected to find #{type} Token here. Instead found #{@lookahead.type}"
			@error_count += 1
      		end
      		consume()
   	end
   	
	# "Might" need to modify this. Errors?
	def program()
		@error_count = 0
		if (@lookahead.type == Token::EOF) 
			abort("File is empty")
		end     		
		while(@lookahead.type != Token::EOF)
			statement()  
      		end
		if (@error_count > 0)
			puts "There were #{@error_count} parse errors found."
		else
			puts "Program parsed with no errors"
		end
   	end

	def statement()
		puts "Entering STMT Rule"
		if (@lookahead.type == Token::PRINT)
			puts "Found PRINT Token: #{@lookahead.text}"
			consume()
			exp()
		else
			assign()
		end
		puts "Exiting STMT Rule"
	end

	def assign()
		#Check if there's an ID by calling id(), then check for = then call exp()		
		puts "Entering ASSGN Rule"
		id()
		if (@lookahead.type == Token::ASSGN)
			puts "Found ASSGN Token: #{@lookahead.text}"
			consume()
		else 
			match(Token::ASSGN, "ASSGN")
		end
		exp()
		puts "Exiting ASSGN Rule"
	end

	def exp()
		#Check for term, then check for etail
		puts "Entering EXP Rule"
		term()
		etail()
		puts "Exiting EXP Rule"
	end

	def etail()
		#Check for + or -, if so make sure there's a term then an etail
		#If neither + or -, epsilon
		puts "Entering ETAIL Rule"
		if (@lookahead.type == Token::ADDOP)
			puts "Found ADDOP Token: #{@lookahead.text}"
			consume()
			term()
			etail()
		elsif (@lookahead.type == Token::SUBOP)
			puts "Found SUBOP Token: #{@lookahead.text}"
			consume()
			term()
			etail()
		else
			puts "Did not find ADDOP or SUBOP Token, choosing EPSILON production"
		end
		puts "Exiting ETAIL Rule"
	end

	def term()
		#Check for factor, then ttail
		puts "Entering TERM Rule"
		factor()
		ttail()
		puts "Exiting TERM Rule"
	end

	def ttail()
		#Check for * or /, if so make sure there's a term then a ttail
		#If neither * or /, epsilon
		puts "Entering TTAIL Rule"
		if (@lookahead.type == Token::MULTOP)
			puts "Found MULTOP Token: #{@lookahead.text}"
			consume()
			factor()
			ttail()
		elsif (@lookahead.type == Token::DIVOP)
			puts "Found DIVOP Token: #{@lookahead.text}"
			consume()
			factor()
			ttail()
		else
			puts "Did not find MULTOP or DIVOP Token, choosing EPSILON production"
		end
		puts "Exiting TTAIL Rule"
	end

	def factor()
		#Check if it starts with (, if so check for an expression then a )
		#Otherwise check for INT or ID
		puts "Entering FACTOR Rule"
		if (@lookahead.type == Token::LPAREN)
			puts "Found LPAREN Token: #{@lookahead.text}"
			consume()
			exp()
			if (@lookahead.type == Token::RPAREN)
				puts "Found RPAREN Token: #{@lookahead.text}"
				consume()
			else
				match(Token::RPAREN, "RPAREN")
			end
		elsif (@lookahead.type == Token::INT)
			puts "Found INT Token: #{@lookahead.text}"
			consume()
		elsif (@lookahead.type == Token::ID)
			puts "Found ID Token: #{@lookahead.text}"
			consume()
		else
			puts "Expected to see ( or INT Token or ID Token. Instead found " + 				"#{@lookahead.type}"
			consume()
			@error_count +=1
		end
		puts "Exiting FACTOR Rule"
	end

	def id()
		puts "Entering ID Rule"
		if (@lookahead.type == Token::ID)
			puts "Found ID Token: #{@lookahead.text}"
			consume()
		else
			match(Token::ID, "ID")
		end
		puts "Exiting ID Rule"
	end
end
