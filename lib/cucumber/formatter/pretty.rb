require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    # This formatter prints features to plain text - exactly how they were parsed,
    # just prettier. That means with proper indentation and alignment of table columns.
    #
    # If the output is STDOUT (and not a file), there are bright colours to watch too.
    #
    class Pretty < Ast::Visitor
      include Console
      attr_writer :indent

      def initialize(step_mother, io, options, delim='|')
        super(step_mother)
        @io = io
        @options = options
        @delim = delim
      end

      def visit_features(features)
        super
        print_summary(@io, features)
      end

      def visit_feature(feature)
        @indent = 0
        feature.accept(self)
      end

      def visit_comment(comment)
        comment.accept(self)
      end

      def visit_comment_line(comment_line)
        unless comment_line.blank?
          @io.puts(comment_line.indent(@indent)) 
          @io.flush
        end
      end

      def visit_tags(tags)
        tags.accept(self)
        if @indent == 1
          @io.puts 
          @io.flush
        end
      end

      def visit_tag_name(tag_name)
        tag = format_string("@#{tag_name}", :tag).indent(@indent)
        @io.print(tag)
        @io.flush
        @indent = 1
      end

      def visit_feature_name(name)
        @io.puts(name)
        @io.puts
        @io.flush
      end

      def visit_feature_element(feature_element)
        @indent = 2
        @last_undefined = feature_element.undefined?
        feature_element.accept(self)
        @io.puts
        @io.flush
      end

      def visit_examples(examples)
        examples.accept(self)
      end

      def visit_examples_name(keyword, name)
        @io.puts("\n  #{keyword} #{name}")
        @io.flush
        @indent = 4
      end

      def visit_scenario_name(keyword, name, file_line, source_indent)
        line = "  #{keyword} #{name}"
        line = format_string(line, :undefined) if @last_undefined
        @io.print(line)
        if @options[:source]
          line_comment = " # #{file_line}".indent(source_indent)
          @io.print(format_string(line_comment, :comment))
        end
        @io.puts
        @io.flush
      end

      def visit_step(step)
        @indent = 6
        exception = step.accept(self)
        print_exception(@io, exception, @indent) if exception
      end

      def visit_step_name(keyword, step_name, status, step_definition, source_indent)
        source_indent = nil unless @options[:source]
        formatted_step_name = format_step(keyword, step_name, status, step_definition, source_indent)
        @io.puts("    " + formatted_step_name)
        @io.flush
      end

      def visit_multiline_arg(multiline_arg, status)
        multiline_arg.accept(self, status)
      end

      def visit_table_row(table_row, status)
        @io.print @delim.indent(@indent)
        exception = table_row.accept(self, status)
        @io.puts
        print_exception(@io, exception, 6) if exception
      end

      def visit_py_string(string, status)
        s = "\"\"\"\n#{string}\n\"\"\"".indent(@indent)
        @io.puts(format_string(s, status))
        @io.flush
      end

      def visit_table_cell(table_cell, status)
        table_cell.accept(self, status)
      end

      def visit_table_cell_value(value, width, status)
        @io.print(' ' + format_string((value || '').ljust(width), status) + " #{@delim}")
        @io.flush
      end

      private

      def print_summary(io, features)
        print_counts(io, features)
        print_snippets(io, features, @options)
      end

    end
  end
end
