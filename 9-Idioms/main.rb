# frozen_string_literal: true

require_relative 'modules/company_name'
require_relative 'modules/instance_counter'
require_relative 'modules/validation'
require_relative 'modules/service'
require_relative 'modules/msgs'
require_relative 'modules/menu'
require_relative 'trains/train'
require_relative 'trains/train_passenger'
require_relative 'trains/train_cargo'
require_relative 'vagons/vagon'
require_relative 'vagons/vagon_passenger'
require_relative 'vagons/vagon_cargo'
require_relative 'route'
require_relative 'station'

class Main
  include Menu
  include Msgs
  include Service

  attr_reader :stations, :trains, :vagons, :routes

  def initialize
    @stations = []
    @trains = []
    @vagons = []
    @routes = []
  end

  def menu
    loop do
      show_menu('Основное меню:', MAIN_MENU)
      case gets.chomp
      when '1' then create_menu
      when '2' then info_menu
      when '3' then operation_menu
      when '0' then exit
      else input_error
      end
    end
  end

  def create_menu
    loop do
      show_menu('Создать:', CREATE_MENU)
      case gets.chomp
      when '1' then create_station
      when '2' then create_train
      when '3' then create_vagon
      when '4' then create_route
      when '0' then return
      else input_error
      end
    end
  end

  def info_menu
    loop do
      show_menu('Информация:', INFO_MENU)
      case gets.chomp
      when '1' then stations_list #items_list(stations)
      when '2' then trains_list #items_list(trains)
      when '3' then stations_with_trains
      when '4' then items_list(vagons)
      when '5' then trains_with_vagons
      when '6' then items_list(routes)
      when '0' then return
      else input_error
      end
    end
  end

  def operation_menu
    loop do
      show_menu('Операции:', OPERATION_MENU)
      case gets.chomp
      when '1' then assign_route
      when '2' then add_or_delete_vagon
      when '3' then go_train
      when '4' then add_station
      when '5' then delete_station
      when '6' then reserve
      when '0' then return
      else input_error
      end
    end
  end

  protected

  attr_writer :stations, :trains, :vagons, :routes

  def create_station
    station_name_input
    @stations << Station.new(@station)
    station_created
  rescue NameError => e
    puts e.message
    try_again
    retry
  end

  def create_train
    train_number_input
    train_type_input
    if train_valid?
      case @train_type
      when 'cargo' then @trains << TrainCargo.new(@train_number)
      when 'passenger' then @trains << TrainPassenger.new(@train_number)
      else try_again
      end
      train_created
    end
  rescue RuntimeError, TypeError => e
    puts e.message
    try_again
    retry
  end

  def create_vagon
    create_vagon_input
    if vagon_valid?
      case @vagon_type
      when 'cargo' then @vagons << VagonCargo.new(@vagon_number, @space)
      when 'passenger' then @vagons << VagonPassenger.new(@vagon_number, @space)
      else try_again
      end
      vagon_created
    end
  rescue RuntimeError, TypeError => e
    puts e.message
    try_again
    retry
  end

  def create_route
    if stations.size >= 2
      start_station = choice_item(stations)
      end_station = choice_item(stations)
      if stations[start_station] == stations[end_station]
        puts 'Same stations error'
      else
        route = Route.new(stations[start_station], stations[end_station])
        @routes << route
        puts "Маршрут создан. Станции: #{route.stations.first.name} - #{route.stations.last.name}"
      end
    else
      not_enough_stations
    end
  end

  def reserve
    return unless choice_item(vagons)

    vagon = vagons[@item_index]
    puts "Свободно: #{vagon.available_space}"
    case vagon
    when VagonPassenger then buy_ticket(vagon)
    when VagonCargo then take_volume(vagon)
    end
  end

  # def change_route
  #   return unless choice_item(routes) && choice_item(stations)

  #   route = routes[@item_index]
  #   station = stations[@item_index]
  #   # station_name_input
  #   puts '1 - Добавить станцию или 2 - Удалить станцию?'
  #   case gets.chomp.to_i
  #   when 1 then route.add_station(station)
  #   when 2 then route.delete_station(station)
  #   end
  # end

  def add_station
    return unless choice_item(routes)

    route = routes[@item_index]
    station_name_input
    stations << Station.new(@station) if stations.none?(@station)
    route.add_station(@station)
  end

  def delete_station
    return unless choice_item(routes)

    route = routes[@item_index]
    station_name_input
    route.delete_station(@station)
  end

  def assign_route
    return unless choice_item(trains) && choice_item(routes)

    train = trains[@item_index]
    route = routes[@item_index]
    train.route = route
    current_station
    station = train.current_station
    station.add_train(train)
  end

  def add_or_delete_vagon
    return unless choice_item(trains) && choice_item(vagons)

    train = trains[@item_index]
    vagon = vagons[@item_index]
    puts '1 - Добавить вагон или 2 - Удалить вагон?'
    case gets.chomp.to_i
    when 1 then train.add_vagons(vagon)
    when 2 then train.delete_vagons(vagon)
    end
  rescue RuntimeError => e
    puts e.message
  end

  def go_train
    if choice_item(trains)
      train = trains[@item_index]
      train.current_station.send_train(train)
      go_train_choice(train)
      train.current_station.add_train(train)
      current_station
    else
      set_a_route
    end
  end

  def go_train_choice(train)
    puts '1 - Вперёд или 2 - Назад?'
    case gets.chomp.to_i
    when 1 then train.go_next_station
    when 2 then train.go_previous_station
    end
  end
end

# def go_next_station
#   if choice_item(trains)
#     train = trains[@item_index]
#     train.current_station.send_train(train)
#     train.go_next_station
#     train.current_station.add_train(train)
#     current_station
#   else
#     set_a_route
#   end
# end

# def go_previous_station
#   if choice_item(trains)
#     train = trains[@item_index]
#     train.current_station.send_train(train)
#     train.go_previous_station
#     train.current_station.add_train(train)
#     current_station
#   else
#     set_a_route
#   end
# end

# def add_vagon
#   return unless choice_item(trains) && choice_item(vagons)

#   train = trains[@item_index]
#   vagon = vagons[@item_index]
#   train.add_vagons(vagon)
# rescue RuntimeError => e
#   puts e.message
# end

# def delete_vagon
#   return unless choice_item(trains) && choice_item(vagons)

#   train = trains[@item_index]
#   vagon = vagons[@item_index]
#   train.delete_vagons(vagon)
# rescue RuntimeError => e
#   puts e.message
# end
