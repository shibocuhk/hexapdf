# -*- encoding: utf-8 -*-
#
#--
# This file is part of HexaPDF.
#
# HexaPDF - A Versatile PDF Creation and Manipulation Library For Ruby
# Copyright (C) 2014-2017 Thomas Leitner
#
# HexaPDF is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License version 3 as
# published by the Free Software Foundation with the addition of the
# following permission added to Section 15 as permitted in Section 7(a):
# FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY
# THOMAS LEITNER, THOMAS LEITNER DISCLAIMS THE WARRANTY OF NON
# INFRINGEMENT OF THIRD PARTY RIGHTS.
#
# HexaPDF is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public
# License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with HexaPDF. If not, see <http://www.gnu.org/licenses/>.
#
# The interactive user interfaces in modified source and object code
# versions of HexaPDF must display Appropriate Legal Notices, as required
# under Section 5 of the GNU Affero General Public License version 3.
#
# In accordance with Section 7(b) of the GNU Affero General Public
# License, a covered work must retain the producer line in every PDF that
# is created or manipulated using HexaPDF.
#++

require 'hexapdf/configuration'
require 'hexapdf/font_loader'

module HexaPDF
  class Document

    # This class provides utility functions for working with fonts. It is available through the
    # HexaPDF::Document#fonts method.
    class Fonts

      # Creates a new Fonts object for the given PDF document.
      def initialize(document)
        @document = document
        @loaded_fonts_cache = {}
      end

      # :call-seq:
      #   fonts.load(name, **options)            -> font
      #
      # Loads and returns the font (using the loaders specified with the configuration option
      # 'font_loaders').
      #
      # If a font with the same parameters has been loaded before, the cached font object is used.
      def load(name, **options)
        options[:variant] ||= :none # assign default value for consistency with caching
        font = @loaded_fonts_cache[[name, options]]
        return font if font

        each_font_loader do |loader|
          font = loader.call(@document, name, **options)
          break if font
        end

        if font
          @loaded_fonts_cache[[name, options]] = font
        else
          raise HexaPDF::Error, "The requested font '#{name}' couldn't be found"
        end
      end

      private

      # :call-seq:
      #   fonts.each_font_loader {|loader| block}
      #
      # Iterates over all configured font loaders.
      def each_font_loader
        @document.config['font_loader'].each_index do |index|
          loader = @document.config.constantize('font_loader', index) do
            raise HexaPDF::Error, "Couldn't retrieve font loader ##{index} from configuration"
          end
          yield(loader)
        end
      end

    end

  end
end
