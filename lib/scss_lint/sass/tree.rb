# Contains extensions of Sass::Tree::Nodes to add support for traversing the
# Sass::Script::Node parse trees contained within the nodes. This probably
# breaks the Sass compiler, but since we're only doing lints this is fine for
# now.
module Sass::Tree
  # Ignore documentation lints as these aren't original implementations.
  # rubocop:disable Documentation

  # Define some common helper code for use in the various monkey patchings.
  class Node
    # Stores node for which this node is a direct child
    attr_accessor :node_parent

    # The `args` field of some Sass::Tree::Node classes returns
    # Sass::Script::Variable nodes with no line numbers. This adds the line
    # numbers back in so lint reporting works for those nodes.
    def add_line_numbers_to_args(arg_list)
      arg_list.each do |variable, _default_expr|
        add_line_number(variable)
      end
    end

    # The Sass parser sometimes doesn't assign line numbers in cases where it
    # should. This is a helper to easily correct that.
    def add_line_number(node)
      node.line ||= line if node.is_a?(::Sass::Script::Tree::Node)
      node
    end

    # Sometimes the parse tree doesn't return a Sass::Script::Variable, but just
    # the name of the variable. This helper takes that name and turns it back
    # into a Sass::Script::Variable that supports lint reporting.
    def create_variable(var_name)
      ::Sass::Script::Tree::Variable.new(var_name).tap do |v|
        v.line = line # Use line number of the containing parse tree node
      end
    end

    # A number of tree nodes return lists that have strings and
    # Sass::Script::Nodes interspersed within them. This returns a filtered list
    # of just those nodes.
    def extract_script_nodes(list)
      list.select { |item| item.is_a?(::Sass::Script::Tree::Node) }
    end

    # Takes a list of arguments, be they arrays or individual objects, and
    # returns a single flat list that can be passed to
    # Sass::Tree::Visitors::Base#visit_children.
    def concat_expr_lists(*expr_lists)
      expr_lists.flatten.compact
    end

    def scss?
      options && options[:syntax] == :scss
    end
  end

  class CommentNode
    def children
      concat_expr_lists super, extract_script_nodes(value)
    end
  end

  class DebugNode
    def children
      if scss?
        concat_expr_lists super, expr
      else
        super
      end
    end
  end

  class DirectiveNode
    def children
      begin
        additional_children = extract_script_nodes(value)
      rescue NotImplementedError # rubocop:disable HandleExceptions
        # Directive nodes may not define `value`
      end
      concat_expr_lists super, additional_children
    end
  end

  class EachNode
    def children
      loop_vars = vars.map { |var| create_variable(var) }

      concat_expr_lists super, loop_vars, list
    end
  end

  class ExtendNode
    def children
      concat_expr_lists super, extract_script_nodes(selector)
    end
  end

  class ForNode
    def children
      concat_expr_lists super, create_variable(var), from, to
    end
  end

  class FunctionNode
    def children
      add_line_numbers_to_args(args)

      concat_expr_lists super, args, splat
    end
  end

  class IfNode
    def children
      if scss?
        concat_expr_lists super, expr
      else
        super
      end
    end
  end

  class MixinDefNode
    def children
      if scss?
        add_line_numbers_to_args(args)

        concat_expr_lists super, args, splat
      else
        add_line_numbers_to_args(args)
        super
      end
    end
  end

  class MixinNode
    def children
      if scss?
        add_line_numbers_to_args(args)

        # Keyword mapping is String -> Expr, so convert the string to a variable
        # node that supports lint reporting
        keyword_exprs = keywords.as_stored.map do |var_name, var_expr|
          [create_variable(var_name), var_expr]
        end if keywords.any?

        concat_expr_lists super, args, keyword_exprs, splat
      else
        add_line_numbers_to_args(args)
        super
      end
    end
  end

  class PropNode
    def children
      if scss?
        concat_expr_lists super, extract_script_nodes(name), add_line_number(value)
      else
        add_line_number(value)
        super
      end
    end
  end

  class ReturnNode
    def children
      concat_expr_lists super, expr
    end
  end

  class RuleNode
    def children
      concat_expr_lists super, extract_script_nodes(rule)
    end
  end

  class VariableNode
    def children
      if scss?
        concat_expr_lists super, expr
      else
        super
      end
    end
  end

  class WarnNode
    def children
      concat_expr_lists super, expr
    end
  end

  class WhileNode
    def children
      concat_expr_lists super, expr
    end
  end
end
