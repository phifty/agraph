
module AllegroGraph

  module Utility

    module ParameterMapper

      MAP = {
        :strip_width    => { :to => :stripWidth,  :for => [ :cartesian_type, :spherical_type ], :default => 1 },
        :x_min          => { :to => :xmin,        :for => [ :cartesian_type, :find_inside_box ] },
        :y_min          => { :to => :ymin,        :for => [ :cartesian_type, :find_inside_box ] },
        :x_max          => { :to => :xmax,        :for => [ :cartesian_type, :find_inside_box ] },
        :y_max          => { :to => :ymax,        :for => [ :cartesian_type, :find_inside_box ] },
        :unit           => { :to => :unit,        :for => [ :spherical_type, :find_inside_haversine ], :default => :degree },
        :latitude_min   => { :to => :latmin,      :for => [ :spherical_type ] },
        :longitude_min  => { :to => :longmin,     :for => [ :spherical_type ] },
        :latitude_max   => { :to => :latmax,      :for => [ :spherical_type ] },
        :longitude_max  => { :to => :longmax,     :for => [ :spherical_type ] },
        :name           => { :to => :resource,    :for => [ :create_polygon ], :modifier => [ :quote ] },
        :type           => { :to => :type,        :for => [ :find_inside_box, :find_inside_circle, :find_inside_haversine, :find_inside_polygon ] },
        :predicate      => { :to => :predicate,   :for => [ :find_inside_box, :find_inside_circle, :find_inside_haversine, :find_inside_polygon ] },
        :x              => { :to => :x,           :for => [ :find_inside_circle ] },
        :y              => { :to => :y,           :for => [ :find_inside_circle ] },
        :radius         => { :to => :radius,      :for => [ :find_inside_circle, :find_inside_haversine ] },
        :latitude       => { :to => :lat,         :for => [ :find_inside_haversine ], :modifier => :latitude_to_iso },
        :longitude      => { :to => :long,        :for => [ :find_inside_haversine ], :modifier => :longitude_to_iso },
        :polygon_name   => { :to => :polygon,     :for => [ :find_inside_polygon ], :modifier => [ :quote ] }
      }.freeze unless defined?(MAP)

      def self.map(parameters, method_name)
        result = { }
        MAP.each do |key, mapping|
          value = parameters[key] || mapping[:default]
          required = [ mapping[:for] ].flatten.include? method_name.to_sym
          if required
            if value
              [ mapping[:modifier] ].flatten.compact.each do |modifier|
                value = send modifier, value
              end
              result[ mapping[:to] ] = value.to_s
            else
              raise ArgumentError, "missing parameter :#{key}!"
            end
          end
        end
        result
      end

      def self.quote(value)
        "\"#{value}\""
      end

      def self.latitude_to_iso(value)
        float_to_iso value, 2
      end

      def self.longitude_to_iso(value)
        float_to_iso value, 3
      end

      private

      def self.float_to_iso(value, digits)
        sign = "+"
        if value < 0
          sign = "-"
          value = -value
        end
        floor = value.to_i
        sign + (("%%0%dd" % digits) % floor) + (".%07d" % ((value - floor) * 10000000))
      end

    end

  end

end
