
KBELuaUtil = KBEngine.KBELuaUtil;

function table.removeItem(list, item, removeAll)
  local rmCount = 0
  for i = 1, #list do
    if list[i - rmCount] == item then
      table.remove(list, i - rmCount)
      if removeAll then
        rmCount = rmCount + 1
      else
        break
      end
    end
  end
end