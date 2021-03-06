local META = ...

function META:IsFunctionStatement()
    return
        self:IsValue("function") or
        (self:IsValue("local") and self:GetTokenOffset(1).value == "function")
end

local function read_call_body(self, node)
    local start = self:GetToken()

    node.tokens["func("] = self:ReadExpectValue("(")
    node.arguments = self:IdentifierList()
    node.tokens["func)"] = self:ReadExpectValue(")", start, start)
    node.block = self:Block({["end"] = true})
    node.tokens["end"] = self:ReadExpectValue("end")

    return node
end

function META:ReadFunctionStatement()
    local node = self:Node("function")

    if self:IsValue("local") then
        node.tokens["local"] = self:ReadToken("local")
		node.tokens["function"] = self:ReadExpectValue("function")

		node.value = self:Node("value")
		node.value.value = self:ReadExpectType("letter")
		node.is_local = true
    else
        node.tokens["function"] = self:ReadExpectValue("function")
        node.value = self:Expression(0, true)
    end

    return read_call_body(self, node)
end

function META:AnonymousFunction()
    local node = self:Node("function")
    node.tokens["function"] = self:ReadExpectValue("function")

    return read_call_body(self, node)
end