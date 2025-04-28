-- this is all the chess specific stuff, see 00001.lua for more DK specific lua functions
-- this code is based on the file found here changed to work with the DK lua engine, and optimized for speed
-- https://github.com/soumith/sunfish.lua
-- wich in turn was based on https://github.com/thomasahle/sunfish
-- Code License: BSD

local ffi = require("ffi")

ffi.cdef[[
typedef int8_t Board[120];
typedef struct { int16_t from; int16_t to; } Move;
typedef Move MoveList[512];  // Big enough for all moves
]]


-- The table size is the maximum number of elements in the transposition table.
local TABLE_SIZE = 1e6

-- This constant controls how much time we spend on looking for optimal moves.
local NODES_SEARCHED = 1e2

-- Mate value must be greater than 8*queen + 2*(rook+knight+bishop)
-- King value is set to twice this value such that if the opponent is
-- 8 queens up, but we got the king, we still exceed MATE_VALUE.
local MATE_VALUE = 30000

-- Our board is represented as a 120 character string. The padding allows for
-- fast detection of moves that don't stay within the board.
local A1, H1, A8, H8 = 91, 98, 21, 28

local initial =
'         \n' .. --   0 -  9
    '         \n' .. --  10 - 19
    ' rnbqkbnr\n' .. --  20 - 29
    ' pppppppp\n' .. --  30 - 39
    ' ........\n' .. --  40 - 49
    ' ........\n' .. --  50 - 59
    ' ........\n' .. --  60 - 69
    ' ........\n' .. --  70 - 79
    ' PPPPPPPP\n' .. --  80 - 89
    ' RNBQKBNR\n' .. --  90 - 99
    '         \n' .. -- 100 -109
    '          ' -- 110 -119

-------------------------------------------------------------------------------
-- Move and evaluation tables
-------------------------------------------------------------------------------
local N, E, S, W = -10, 1, 10, -1
local directions = {
    P = { N, 2 * N, N + W, N + E },
    N = { 2 * N + E, N + 2 * E, S + 2 * E, 2 * S + E, 2 * S + W, S + 2 * W, N + 2 * W, 2 * N + W },
    B = { N + E, S + E, S + W, N + W },
    R = { N, E, S, W },
    Q = { N, E, S, W, N + E, S + E, S + W, N + W },
    K = { N, E, S, W, N + E, S + E, S + W, N + W }
}

local pst = {
    P = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 198, 198, 198, 198, 198, 198, 198, 198, 0,
        0, 178, 198, 198, 198, 198, 198, 198, 178, 0,
        0, 178, 198, 198, 198, 198, 198, 198, 178, 0,
        0, 178, 198, 208, 218, 218, 208, 198, 178, 0,
        0, 178, 198, 218, 238, 238, 218, 198, 178, 0,
        0, 178, 198, 208, 218, 218, 208, 198, 178, 0,
        0, 178, 198, 198, 198, 198, 198, 198, 178, 0,
        0, 198, 198, 198, 198, 198, 198, 198, 198, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    B = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 797, 824, 817, 808, 808, 817, 824, 797, 0,
        0, 814, 841, 834, 825, 825, 834, 841, 814, 0,
        0, 818, 845, 838, 829, 829, 838, 845, 818, 0,
        0, 824, 851, 844, 835, 835, 844, 851, 824, 0,
        0, 827, 854, 847, 838, 838, 847, 854, 827, 0,
        0, 826, 853, 846, 837, 837, 846, 853, 826, 0,
        0, 817, 844, 837, 828, 828, 837, 844, 817, 0,
        0, 792, 819, 812, 803, 803, 812, 819, 792, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    },
    N = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 627, 762, 786, 798, 798, 786, 762, 627, 0,
        0, 763, 798, 822, 834, 834, 822, 798, 763, 0,
        0, 817, 852, 876, 888, 888, 876, 852, 817, 0,
        0, 797, 832, 856, 868, 868, 856, 832, 797, 0,
        0, 799, 834, 858, 870, 870, 858, 834, 799, 0,
        0, 758, 793, 817, 829, 829, 817, 793, 758, 0,
        0, 739, 774, 798, 810, 810, 798, 774, 739, 0,
        0, 683, 718, 742, 754, 754, 742, 718, 683, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    R = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1258, 1263, 1268, 1272, 1272, 1268, 1263, 1258, 0,
        0, 1258, 1263, 1268, 1272, 1272, 1268, 1263, 1258, 0,
        0, 1258, 1263, 1268, 1272, 1272, 1268, 1263, 1258, 0,
        0, 1258, 1263, 1268, 1272, 1272, 1268, 1263, 1258, 0,
        0, 1258, 1263, 1268, 1272, 1272, 1268, 1263, 1258, 0,
        0, 1258, 1263, 1268, 1272, 1272, 1268, 1263, 1258, 0,
        0, 1258, 1263, 1268, 1272, 1272, 1268, 1263, 1258, 0,
        0, 1258, 1263, 1268, 1272, 1272, 1268, 1263, 1258, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    Q = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 0,
        0, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 0,
        0, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 0,
        0, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 0,
        0, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 0,
        0, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 0,
        0, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 0,
        0, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 2529, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    K = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 60098, 60132, 60073, 60025, 60025, 60073, 60132, 60098, 0,
        0, 60119, 60153, 60094, 60046, 60046, 60094, 60153, 60119, 0,
        0, 60146, 60180, 60121, 60073, 60073, 60121, 60180, 60146, 0,
        0, 60173, 60207, 60148, 60100, 60100, 60148, 60207, 60173, 0,
        0, 60196, 60230, 60171, 60123, 60123, 60171, 60230, 60196, 0,
        0, 60224, 60258, 60199, 60151, 60151, 60199, 60258, 60224, 0,
        0, 60287, 60321, 60262, 60214, 60214, 60262, 60321, 60287, 0,
        0, 60298, 60332, 60273, 60225, 60225, 60273, 60332, 60298, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
}

-------------------------------------------------------------------------------
-- Chess logic
-------------------------------------------------------------------------------
Position = {}

function Position.new(board_string, score, wc, bc, ep, kp)
    local self = {}
    self.board = ffi.new("Board")
    for i = 0, #board_string - 1 do
        self.board[i] = board_string:byte(i + 1)
    end
    self.score = score
    self.wc = wc
    self.bc = bc
    self.ep = ep
    self.kp = kp
    for k, v in pairs(Position) do self[k] = v end
    return self
end

function Position:genMoves()
    local moves = ffi.new("MoveList")
    local move_count = 0

    for i = 0, 119 do
        local p = self.board[i]
        if p >= 65 and p <= 90 then  -- isupper
            local piece = string.char(p)
            local dirs = directions[piece]
            if dirs then
                for _, d in ipairs(dirs) do
                    local limit = i + d + 10000 * d
                    for j = i + d, limit, d do
                        local q = self.board[j]
                        if q == 32 or q == 10 then break end -- isspace
                        -- Castling
                        if i == A1 and q == 75 and self.wc[1] then
                            moves[move_count].from = j
                            moves[move_count].to = j - 2
                            move_count = move_count + 1
                        elseif i == H1 and q == 75 and self.wc[2] then
                            moves[move_count].from = j
                            moves[move_count].to = j + 2
                            move_count = move_count + 1
                        end
                        if q >= 65 and q <= 90 then break end -- isupper
                        if piece == 'P' then
                            if (d == N+W or d == N+E) and q == 46 and j ~= self.ep and j ~= self.kp then break end
                            if (d == N or d == 2*N) and q ~= 46 then break end
                            if d == 2*N and (i < A1+N or self.board[i+N] ~= 46) then break end
                        end
                        moves[move_count].from = i
                        moves[move_count].to = j
                        move_count = move_count + 1
                        if piece == 'P' or piece == 'N' or piece == 'K' then break end
                        if q >= 97 and q <= 122 then break end -- islower
                    end
                end
            end
        end
    end

        -- Copy FFI move list to Lua table
    local moves_lua = {}
    for idx = 0, move_count - 1 do
        local m = moves[idx]
        moves_lua[#moves_lua + 1] = { m.from, m.to }
    end
    return moves_lua

    --return moves, move_count
end

function Position:rotate()
    local new_board = ffi.new("Board")
    for i = 0, 119 do
        local c = self.board[119 - i]
        -- Swap case manually
        if c >= 65 and c <= 90 then -- isupper
            new_board[i] = c + 32 -- tolower
        elseif c >= 97 and c <= 122 then -- islower
            new_board[i] = c - 32 -- toupper
        else
            new_board[i] = c -- keep space or dot
        end
    end

    return self.new(
        ffi.string(new_board, 120), -- convert to string for constructor
        -self.score,
        self.bc,
        self.wc,
        119 - self.ep,
        119 - self.kp
    )
end

local function makeMove(from, to)
    local m = ffi.new("Move")
    m.from = from
    m.to = to
    return m
end
function Position:move(move)

    local m = nil
    if move.from then
        -- It's a FFI struct
        m = move
    else
        -- It's a Lua table
        m = makeMove(move[1], move[2])
    end


    local i, j = m.from, m.to
    local new_board = ffi.new("Board")
    ffi.copy(new_board, self.board, 120)

    local wc, bc, ep, kp = self.wc, self.bc, 0, 0
    local p, q = new_board[i], new_board[j]
    local score = self.score + self:value({i,j})

    new_board[j] = p
    new_board[i] = string.byte('.')

    if i == A1 then wc = { false, wc[2] } end
    if i == H1 then wc = { wc[1], false } end
    if j == A8 then bc = { bc[1], false } end
    if j == H8 then bc = { false, bc[2] } end

    if p == 75 then -- 'K'
        wc = { false, false }
        if math.abs(j - i) == 2 then
            kp = math.floor((i + j) / 2)
            new_board[j < i and A1 or H1] = string.byte('.')
            new_board[kp] = string.byte('R')
        end
    end

    if p == 80 then -- 'P'
        if A8 <= j and j <= H8 then
            new_board[j] = string.byte('Q')
        end
        if j - i == 2 * N then
            ep = i + N
        end
        if ((j - i) == N + W or (j - i) == N + E) and q == 46 then
            new_board[j+S] = string.byte('.')
        end
    end

    -- Make a string again for the next position
    local new_board_str = {}
    for idx = 0, 119 do
        new_board_str[#new_board_str+1] = string.char(new_board[idx])
    end
    return Position.new(table.concat(new_board_str), score, wc, bc, ep, kp):rotate()
end

function Position:value(move)
    assert(move, "Position:value() got nil move")

    local i, j
    if move.from then
        -- FFI struct
        i, j = move.from, move.to
    else
        -- Lua table fallback
        i, j = move[1], move[2]
    end

    assert(i and j, "Position:value() got nil i or j")

    local p, q = self.board[i], self.board[j]
    assert(p, "p nil at " .. tostring(i))
    assert(q, "q nil at " .. tostring(j))

    local score = pst[string.char(p)][j + 1] - pst[string.char(p)][i + 1]

    -- Capture
    if q >= 97 and q <= 122 then -- islower
        score = score + pst[string.char(q):upper()][j + 1]
    end

    -- Castling check detection
    if math.abs(j - self.kp) < 2 then
        score = score + pst['K'][j + 1]
    end

    -- Castling
    if p == 75 and math.abs(i - j) == 2 then
        score = score + pst['R'][math.floor((i + j) / 2) + 1]
        score = score - pst['R'][j < i and A1 + 1 or H1 + 1]
    end

    -- Special pawn stuff
    if p == 80 then
        if A8 <= j and j <= H8 then
            score = score + pst['Q'][j + 1] - pst['P'][j + 1]
        end
        if j == self.ep then
            score = score + pst['P'][j + S + 1]
        end
    end

    return score
end

-- the lamest possible and most embarassing namedtuple hasher ordered dict
-- I apologize to the world for writing it.
local tp = {}
local tp_index = {}
local tp_count = 0

local function tp_set(pos, val)
    local b1 = pos.bc[1] and 'true' or 'false'
    local b2 = pos.bc[2] and 'true' or 'false'
    local w1 = pos.bc[1] and 'true' or 'false'
    local w2 = pos.bc[2] and 'true' or 'false'
    local hash = ffi.string(pos.board, 120) .. ';' .. pos.score .. ';' .. w1 .. ';' .. w2 .. ';'
        .. b1 .. ';' .. b2 .. ';' .. pos.ep .. ';' .. pos.kp
    tp[hash] = val
    tp_index[#tp_index + 1] = hash
    tp_count = tp_count + 1
end

local function tp_get(pos)
    local b1 = pos.bc[1] and 'true' or 'false'
    local b2 = pos.bc[2] and 'true' or 'false'
    local w1 = pos.bc[1] and 'true' or 'false'
    local w2 = pos.bc[2] and 'true' or 'false'
    local hash = ffi.string(pos.board, 120) .. ';' .. pos.score .. ';' .. w1 .. ';' .. w2 .. ';'
        .. b1 .. ';' .. b2 .. ';' .. pos.ep .. ';' .. pos.kp
    return tp[hash]
end

local function tp_popitem()
    tp[tp_index[#tp_index]] = nil
    tp_index[#tp_index] = nil
    tp_count = tp_count - 1
end

-------------------------------------------------------------------------------
-- Search logic
-------------------------------------------------------------------------------

local nodes = 0

local function bound(pos, gamma, depth)
    --[[ returns s(pos) <= r < gamma    if s(pos) < gamma
        returns s(pos) >= r >= gamma   if s(pos) >= gamma ]] --
    nodes = nodes + 1

    -- Look in the table if we have already searched this position before.
    -- We use the table value if it was done with at least as deep a search
    -- as ours, and the gamma value is compatible.
    local entry = tp_get(pos)
    assert(depth)
    if entry ~= nil and entry.depth >= depth and (
        entry.score < entry.gamma and entry.score < gamma or
            entry.score >= entry.gamma and entry.score >= gamma) then
        return entry.score
    end

    -- Stop searching if we have won/lost.
    if math.abs(pos.score) >= MATE_VALUE then
        return pos.score
    end

    -- Null move. Is also used for stalemate checking
    local nullscore = depth > 0 and -bound(pos:rotate(), 1 - gamma, depth - 3) or pos.score
    --nullscore = -MATE_VALUE*3 if depth > 0 else pos.score
    if nullscore >= gamma then
        return nullscore
    end

    -- We generate all possible, pseudo legal moves and order them to provoke
    -- cuts. At the next level of the tree we are going to minimize the score.
    -- This can be shown equal to maximizing the negative score, with a slightly
    -- adjusted gamma value.
    local best, bmove = -3 * MATE_VALUE, nil
    local moves = pos:genMoves()
    local function sorter(a, b)
        local va = pos:value(a)
        local vb = pos:value(b)
        if va ~= vb then
            return va > vb
        else
            if a[1] == b[1] then
                return a[2] > b[2]
            else
                return a[1] < b[1]
            end
        end
    end

    table.sort(moves, sorter)
    for _, move in ipairs(moves) do
        -- We check captures with the value function, as it also contains ep and kp
        if depth <= 0 and pos:value(move) < 150 then
            break
        end
        local score = -bound(pos:move(move), 1 - gamma, depth - 1)
        -- print(move[1] .. ' ' ..  move[2] .. ' ' .. score)
        if score > best then
            best = score
            bmove = move
        end
        if score >= gamma then
            break
        end
    end

    -- If there are no captures, or just not any good ones, stand pat
    if depth <= 0 and best < nullscore then
        return nullscore
    end
    -- Check for stalemate. If best move loses king, but not doing anything
    -- would save us. Not at all a perfect check.
    if depth > 0 and (best <= -MATE_VALUE) and nullscore > -MATE_VALUE then
        best = 0
    end

    -- We save the found move together with the score, so we can retrieve it in
    -- the play loop. We also trim the transposition table in FILO order.
    -- We prefer fail-high moves, as they are the ones we can build our pv from.
    if entry == nil or depth >= entry.depth and best >= gamma then
        tp_set(pos, { depth = depth, score = best, gamma = gamma, move = bmove })
        if tp_count > TABLE_SIZE then
            tp_popitem()
        end
    end
    return best
end

function search(pos, maxn)
    -- Iterative deepening MTD-bi search
    maxn = maxn or NODES_SEARCHED
    nodes = 0 -- the global value "nodes"
    local score

    -- We limit the depth to some constant, so we don't get a stack overflow in
    -- the end game.
    for depth = 1, 98 do
        -- The inner loop is a binary search on the score of the position.
        -- Inv: lower <= score <= upper
        -- However this may be broken by values from the transposition table,
        -- as they don't have the same concept of p(score). Hence we just use
        -- 'lower < upper - margin' as the loop condition.
        local lower, upper = -3 * MATE_VALUE, 3 * MATE_VALUE
        while lower < upper - 3 do
            local gamma = math.floor((lower + upper + 1) / 2)
            score = bound(pos, gamma, depth)
            -- print(nodes, gamma, score)
            assert(score)
            if score >= gamma then
                lower = score
            end
            if score < gamma then
                upper = score
            end
        end
        assert(score)

        -- print(string.format("Searched %d nodes. Depth %d. Score %d(%d/%d)", nodes, depth, score, lower, upper))

        -- We stop deepening if the global N counter shows we have spent too
        -- long, or if we have already won the game.
        if nodes >= maxn or math.abs(score) >= MATE_VALUE then
            break
        end
    end

    -- If the game hasn't finished we can retrieve our move from the
    -- transposition table.
    local entry = tp_get(pos)
    if entry ~= nil then
        return entry.move, score
    end
    return nil, score
end

return {  Position = Position, initial = initial, MATE_VALUE = MATE_VALUE,
      A1 = A1 }
