local ROOT_PLY = 1
local MAX_PLY = 10
local INFINITY = 100000000
local WHITE, BLACK = 1, 2
local NULL = -1
local EMPTY = 7

local PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING = 1, 2, 3, 4, 5, 6
local P, N, B, R, Q, K = PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING

local FORWARD = {-8, 8}
local PAWN_RANK = {8, 1}
local PIECE_RANK = {7, 2}
local PROMOTION_RANK = {1, 8}

local STEPS = {}
STEPS[P] = {}
STEPS[N] = {-21, -19, -12, -8, 8, 12, 19, 21}
STEPS[B] = {11, -11, -9, 9}
STEPS[R] = {1, 10, -1, -10}
STEPS[Q] = {-9, 9, -11, 11, -10, 10, -1, 1}
STEPS[K] = {-9, 9, -11, 11, -10, 10, -1, 1}

local SLIDES = {}
SLIDES[P] = false
SLIDES[N] = false
SLIDES[B] = true
SLIDES[R] = true
SLIDES[Q] = true
SLIDES[K] = false

local MATERIAL = {}
MATERIAL[P] = 1
MATERIAL[N] = 3
MATERIAL[B] = 3
MATERIAL[R] = 5
MATERIAL[Q] = 10
MATERIAL[K] = INFINITY
local PIECES = {}
PIECES[WHITE] = {'P','N','B','R','Q','K','_'}
PIECES[BLACK] = {'p','n','b','r','q','k','_'}
local COLORS = {}
COLORS[WHITE] = 'w'
COLORS[BLACK] = 'b'
local UNICODE = {}
UNICODE[WHITE] = {'♙', '♘', '♗', '♖', '♕', '♔', '_'}
UNICODE[BLACK] = {'♟', '♞', '♝', '♜', '♛', '♚', '_'}
local SQUARES = {
  'a8', 'b8', 'c8', 'd8', 'e8', 'f8', 'g8', 'h8',
	'a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7',
	'a6', 'b6', 'c6', 'd6', 'e6', 'f6', 'g6', 'h6',
	'a5', 'b5', 'c5', 'd5', 'e5', 'f5', 'g5', 'h5',
	'a4', 'b4', 'c4', 'd4', 'e4', 'f4', 'g4', 'h4',
	'a3', 'b3', 'c3', 'd3', 'e3', 'f3', 'g3', 'h3',
	'a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2',
	'a1', 'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1'
}
local FEN_INITIAL = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
local FEN_EMPTY = '8/8/8/8/8/8/8/8 w KQkq - 0 1'
local FEN = {
  ['P'] = { color = WHITE, piece = P },
	['N'] = { color = WHITE, piece = N },
	['B'] = { color = WHITE, piece = B },
	['R'] = { color = WHITE, piece = R },
	['Q'] = { color = WHITE, piece = Q },
	['K'] = { color = WHITE, piece = K },
	['p'] = { color = BLACK, piece = P },
	['n'] = { color = BLACK, piece = N },
	['b'] = { color = BLACK, piece = B },
	['r'] = { color = BLACK, piece = R },
	['q'] = { color = BLACK, piece = Q },
	['k'] = { color = BLACK, piece = K },
	['_'] = { color = EMPTY, piece = EMPTY }
}
local FEN_MATCH = {
  ['P'] = 'P',
	['N'] = 'N',
	['B'] = 'B',
	['R'] = 'R',
	['Q'] = 'Q',
	['K'] = 'K',
	['p'] = 'p',
	['n'] = 'n',
	['b'] = 'b',
	['r'] = 'r',
	['q'] = 'q',
	['k'] = 'k',
  ['1'] = '_',
  ['2'] = '__',
  ['3'] = '___',
  ['4'] = '____',
  ['5'] = '_____',
  ['6'] = '______',
  ['7'] = '_______',
  ['8'] = '________'
}
local FEN_INITIAL = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
local FEN_EMPTY = '8/8/8/8/8/8/8/8 w KQkq - 0 1'
local PST = {
  -40,-30,-20,-10,-10,-20,-30,-40,
	-30,-15, -5,  0,  0, -5,-15,-30,
	-20, -5, 10, 15, 15, 10, -5,-20,
	-10,  5, 20, 30, 30, 20,  5,-10,
	-10,  5, 20, 30, 30, 20,  5,-10,
	-20, -5, 10, 15, 15, 10, -5,-20,
	-30,-15, -5,  0,  0, -5,-15,-30,
	-40,-30,-20,-10,-10,-20,-30,-40
}
local SQ = {
   1,  2,  3,  4,  5,  6,  7,  8,
	 9, 10, 11, 12, 13, 14, 15, 16,
	17, 18, 19, 20, 21, 22, 23, 24,
	25, 26, 27, 28, 29, 30, 31, 32,
	33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48,
	49, 50, 51, 52, 53, 54, 55, 56,
	57, 58, 59, 60, 61, 62, 63, 64
}
local SQ64 = {
  22, 23, 24, 25, 26, 27, 28, 29,
	32, 33, 34, 35, 36, 37, 38, 39,
	42, 43, 44, 45, 46, 47, 48, 49,
	52, 53, 54, 55, 56, 57, 58, 59,
	62, 63, 64, 65, 66, 67, 68, 69,
	72, 73, 74, 75, 76, 77, 78, 79,
	82, 83, 84, 85, 86, 87, 88, 89,
	92, 93, 94, 95, 96, 97, 98, 99
}
local SQ120 = {
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1,  1,  2,  3,  4,  5,  6,  7,  8, -1,
	-1,  9, 10, 11, 12, 13, 14, 15, 16, -1,
	-1, 17, 18, 19, 20, 21, 22, 23, 24, -1,
	-1, 25, 26, 27, 28, 29, 30, 31, 32, -1,
	-1, 33, 34, 35, 36, 37, 38, 39, 40, -1,
	-1, 41, 42, 43, 44, 45, 46, 47, 48, -1,
	-1, 49, 50, 51, 52, 53, 54, 55, 56, -1,
	-1, 57, 58, 59, 60, 61, 62, 63, 64, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1
}
-- util
local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- non const globals
local pieces
local colors
local kings
local moves
local nodes
local turnNumber
local ply
local rootMove
local currentSide
local otherSide
local result


local function printBoard()
  local board = ''
  for i = 1, 64 do
    if (i - 1) % 8 == 0 then
      board = board .. "\n"
    end
    if colors[i] == EMPTY then
      board = board .. "_ "
    else
      board = board .. UNICODE[colors[i]][pieces[i]] .. " "
    end
  end
  print(board)
end

local function createMove(from, to, piece, target)
  return {
    from = from,
    to = to,
    piece = piece,
    target = target
  }
end

local function addMove(from, to)
  table.insert(moves[ply], createMove(from, to, pieces[from], pieces[to]))
end

local function swapSides()
  if currentSide == WHITE then
    currentSide, otherSide = BLACK, WHITE
  else
    currentSide, otherSide = WHITE, BLACK
  end
end

local function inCheck()
  local to, step
  local from = kings[currentSide]
  for i = 1, 8 do
    -- debug.debug()
    to = SQ120[SQ64[from] + STEPS[KNIGHT][i]]
    if to ~= NULL and pieces[to] == KNIGHT and colors[to] == otherSide then
      return true
    end
    step = STEPS[KING][i]
    to = SQ120[SQ64[from] + step]
    while to ~= NULL and colors[to] == EMPTY do
      to = SQ120[SQ64[to] + step]
    end
    if to ~= NULL and colors[to] == otherSide then
      if pieces[to] == QUEEN then
        return true
      elseif pieces[to] == BISHOP then
        if i < 5 then
          return true
        end
      elseif pieces[to] == ROOK then
        if i > 4 then
          return true
        end
      elseif pieces[to] == PAWN then
        if math.abs(step - FORWARD[otherSide]) == 1 then
          return true
        end
      elseif pieces[to] == KING then
        if SQ120[SQ64[from] + step] == to then
          return true
        end
      end
    end
  end
  return false
end

local function evaluate()
  local score = 0
  for i = 1, 64 do
    if colors[i] == currentSide then
      score = score + MATERIAL[pieces[i]]
    elseif colors[i] == otherSide then
      score = score - MATERIAL[pieces[i]]
    end
  end
  return score
end

local function unmakeMove(move)
  ply = ply - 1
  swapSides()
  colors[move.from] = currentSide
  pieces[move.from] = move.piece
  if move.target == EMPTY then
    colors[move.to] = EMPTY
  else
    colors[move.to] = otherSide
  end
  pieces[move.to] = move.target
  if move.piece == KING then
    kings[currentSide] = move.from
  end
end

local function makeMove(move)
  ply = ply + 1
  colors[move.to] = currentSide
  pieces[move.to] = move.piece
  colors[move.from] = EMPTY
  pieces[move.from] = EMPTY
  if move.piece == PAWN and (move.to >> 3) == PROMOTION_RANK[currentSide] then
    pieces[move.to] = QUEEN
  elseif move.piece == KING then
    kings[currentSide] = move.to
  end
  if inCheck() then
    swapSides()
    unmakeMove(move)
    return false
  end
  swapSides()
  printBoard()
  return true
end

local function generateMoves()
  moves[ply] = {}
  local step, to
  for from = 1, 64 do
    if colors[from] == currentSide then
      if pieces[from] == PAWN then
        to = from + FORWARD[currentSide]
        if colors[to + 1] == otherSide and SQ120[SQ64[to] + 1] ~= NULL then
          addMove(from, to + 1)
        end
        if colors[to - 1] == otherSide and SQ120[SQ64[to] - 1] ~= NULL then
          addMove(from, to - 1)
        end
        if colors[to] == EMPTY then
          to = to + FORWARD[currentSide]
          if colors[to] == EMPTY and from >> 3 == PAWN_RANK[currentSide] then
            addMove(from, to)
          end
        end
      else
        for i = 1, #STEPS[pieces[from]] do
          step = STEPS[pieces[from]][i]
          to = SQ120[SQ64[from] + step]
          while to ~= NULL do
            if colors[to] ~= currentSide then
              addMove(from, to)
            end
            if not colors[to] == EMPTY and SLIDES[pieces[from]] then
              break
            end
            to = SQ120[SQ64[to] + step]
          end
        end
      end
    end
  end
end

local function alphaBeta(alpha, beta, depth)
  if depth == 0 then
    return evaluate()
  end
  nodes[ply] = nodes[ply] + 1
  generateMoves()
  for i = 1, #moves[ply] do
    local m = moves[ply][i]
    local moveMade = makeMove(m)
    if moveMade then
      local x = -alphaBeta(-beta, -alpha, depth - 1)
      unmakeMove(m)
      if x > alpha then
        if x >= beta then
          return beta
        end
        alpha = x
        if ply == ROOT_PLY then
          rootMove = createMove(m.from, m.to, m.piece, m.target)
        end
      end
    end
  end
  return alpha
end

local function parseFEN(fen)
  local tokens = {}
  for token in string.gmatch(fen, "[^%s]+") do
    table.insert(tokens, token)
  end
  if tokens[2] == 'b' then
    currentSide, otherSide = BLACK, WHITE
  else
    currentSide, otherSide = WHITE, BLACK
  end
  turnNumber = tonumber(tokens[6])
  local board = {}
  local boardString = ''
  local position = tokens[1]
  string.gsub(position, "/", '')
  for i = 1, #position do
    local c = position:sub(i,i)
    if c ~= '/' then
      boardString = boardString .. FEN_MATCH[c]
    end
  end
  for i = 1, #boardString do
    local c = boardString:sub(i,i)
    board[i] = FEN[c]
  end
  for i = 1, 64 do
    colors[i] = board[i].color
    pieces[i] = board[i].piece
    if pieces[i] == KING then
      kings[colors[i]] = i
    end
  end
end

local function generateFEN()
  local rows = {}
  for y = 1, 8 do
    local empty = 0
    local row = ''
    for x = 1, 8 do
      local i = ((y - 1) * 8) + x
      if colors[i] == EMPTY then
        empty = empty + 1
        if x == 8 then
          row = row .. empty
        else
          if empty > 0 then
            row = row .. empty
          end
          empty = 0
          row = row .. PIECES[colors[i]][pieces[i]]
        end
      end
    end
    table.insert(rows, row)
  end
  local position = table.concat(rows, '/')
  return position .. COLORS[currentSide] .. ' - - 0 ' .. turn
end

local function serializeMove(move)
  return dump(move)
end

local function reset()
  pieces = {}
  colors = {}
  kings = {NULL, NULL}
  moves = {}
  nodes = {}
  ply = 1
  turnNumber = 1
  rootMove = nil
  result = nil
  for i = 1, 64 do
    pieces[i] = EMPTY
    colors[i] = EMPTY
  end
  for i = 1, MAX_PLY do
    moves[i] = {}
    nodes[i] = 0
  end
end


local function run(fen, height)
  if not fen then
    fen = FEN_INITIAL
  end
  reset()
  parseFEN(fen)
  local startTime = os.clock()
  alphaBeta(-INFINITY, INFINITY, height)
  if not rootMove then
    return nil
  end
  local totalNodes = 0
  for i = 1, height + 1 do
    totalNodes = totalNodes + nodes[i]
  end
  local searchClock = os.clock() - startTime
  local e = evaluate()
  makeMove(rootMove)
  local c = inCheck()
  return {
    fen = generateFEN(),
    move = serializeMove(rootMove),
    score = e - evaluate(),
    timeElapsed = searchClock,
    nodes = totalNodes,
  }
end

run(FEN_INITIAL, 5)
