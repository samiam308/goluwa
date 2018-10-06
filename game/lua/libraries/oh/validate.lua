local oh = ... or _G.oh

function oh.Validate(ast, code, path)

	-- format error for tonumber({})
	-- not sure where to look for tokens

	local validate_block
	local check_expression
	local scope = {}

	scope.tostring = {
		arguments = {
			{value_type = {"any"}}
		},
		return_types = {
			{"string"}
		},
	}
	scope.print = {
		arguments = {
			{value_type = {"any"}}
		},
		return_types = {
			{"nil"}
		},
	}
	scope.tonumber = {
		arguments = {
			{value_type = {"number", "string"}}
		},
		return_types = {
			{"nil", "number"}
		},
	}

	local function type_compatible(a, b)
		for _, a2 in ipairs(a) do
			for _,b2 in ipairs(b) do
				if a2 == b2 or (a2 == "any" or b2 == "any") then
					return true
				end
			end
		end
		return false
	end

	local function get_key(index_expression)
		local key = ""
		for _, index in ipairs(index_expression) do
			if index.type == "index" then
				key = key .. index.operator.value .. index.value.value
			end
		end
		return key
	end

	local function get_variable(idx_expr)
		if idx_expr[1].type == "function" then
			for _, arg in ipairs(idx_expr[1].arguments) do
				arg.value_type = token2type(arg)
			end
			idx_expr[1].return_types = validate_block(idx_expr[1].body)
			return idx_expr[1]
		end

		local key = get_key(idx_expr)
		local value = scope[key]
		if not value then
			for i, v in ipairs(idx_expr) do
				if v.type ~= "index" then
					print(oh.FormatError(code, path, "undeclared variable " .. key, idx_expr[1].value.start, idx_expr[i - 1].value.stop))
					break
				end
			end
		end
		return value
	end

	local function token2type(node)
		if not node then
			return {"any"}
		end

		if node.value_type then
			return node.value_type
		end

		if node.return_types then
			return node.return_types[1]
		end

		if node.type == "letter" then
			if node.value:find("num", nil, true) then
				return {"number"}
			elseif node.value:find("str", nil, true) then
				return {"string"}
			end
			return {"any"}
		end

		return {node.type}
	end

	local function declare(node)
		if node.type == "assignment" then
			for i, val in ipairs(node.left) do
				node.right[i].value_type = check_expression(node.right[i])
				scope[val.value] = node.right[i]
			end
		elseif node.type == "function" then
			for _, arg in ipairs(node.arguments) do
				arg.value_type = token2type(arg)
				scope[arg.value] = arg
			end
			node.return_types = validate_block(node.body)
			scope[get_key(node.index_expression)] = node
		end
	end

	local function check(node)
		if node.type == "index_call_expression" then
			local index_expression = node.value
			local func = get_variable(index_expression)
			if func then
				for index_i, node in ipairs(index_expression) do
					if node.type == "call" then
						for i, arg in ipairs(func.arguments) do
							local expected = token2type(arg)
							local got
							local error_start
							local error_stop

							if node.arguments[i] then
								local val = node.arguments[i]
								if val.type == "index_expression" then
									got = token2type(get_variable(val.value))
									error_start = val[1].value.value.start or -1
									error_stop = val[1].value.value.stop or -1
								elseif val.type == "table" then
									got = {val.type}
									error_start = val["{"].start
									error_stop = val["}"].stop
								else
									got = {val.type}
									error_start = val.start or -1
									error_stop = val.stop or -1
								end
							else
								got = {"nil"}
								error_start = node["call("].start
								error_stop = node["call)"].stop
							end

							if not type_compatible(expected, got) then
								print(oh.FormatError(code, path, "expected " .. table.concat(expected, "|") .. " to argument #" .. i .. " got " .. table.concat(got, "|"), error_start, error_stop))
							end
						end
						break -- handle return
					end
				end
			end
		elseif node.type == "call" then
			local index_expression = node.value
			check(index_expression)
		end
	end

	local function get_type(var)
		if var.type == "index_call_expression" then
			return token2type(get_variable(var.value))
		end
		return token2type(var)
	end

	function check_expression(expr)
		local left_type, right_type

		if not expr.left or not expr.right then
			check(expr)
			local t = get_type(expr)
			return t, t
		end

		if expr.left.type == "operator" then
			left_type = check_expression(expr.left)
		else
			left_type = get_type(expr.left)
		end

		if expr.right.type == "operator" then
			right_type = check_expression(expr.right)
		else
			right_type = get_type(expr.right)
		end

		if type_compatible(left_type, right_type) then
			print(oh.FormatError(code, path, table.concat(left_type, "|") .. " " .. expr.value.value .. " " .. table.concat(right_type, "|"), expr.value.start, expr.value.stop))
		end

		return left_type, right_type
	end

	function validate_block(block)
		local return_types = {}

		for _, node in ipairs(block) do
			if node.type == "function" or node.type == "assignment" then
				declare(node)
			elseif node.type == "call" then
				check(node)
			elseif node.type == "return" then
				if node.expressions then
					for i, expr in ipairs(node.expressions) do
						local a, b = check_expression(expr)
						if type_compatible(a, b) then
							return_types[i] = a
						else
							return_types[i] = {"any"}
						end
					end
				end
			end
		end

		return return_types
	end
	validate_block(ast)
end

