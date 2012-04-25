class ActionType < ActiveRecord::Base
	ADD = 1
	UPDATE = 2
	DESTROY = 3

	All = [ADD, UPDATE, DESTROY]
end