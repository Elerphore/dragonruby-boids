$gtk.args.state.entities ||= []

$gtk.args.state.screen_width ||= {w: 720.0, h: 720.0}

ENTITY_VECTOR = { dx: 1.0, dy: 1.0 }
ENTITY_SIZE = { w: 10, h: 10 }
ENTITIES_COUNT = 60
SPEED_LIMIT = 2.0
VISUAL_RANGE = 50.0

MIN_DISTANCE = 10.0

AVOID_FACTOR = 0.05
MATCHING_FACTOR = 0.005
CENTERING_FACTOR = 0.005


# / START INITIALIZE SECTION
def init_entities
  $gtk.args.state.entities = []

  ENTITIES_COUNT.each { |i|
    $gtk.args.state.entities.push(
      {
        x: $gtk.args.state.screen_width.w * rand(0.5),
        y: $gtk.args.state.screen_width.h * rand(0.5),
        w: ENTITY_SIZE.w,
        h: ENTITY_SIZE.h,
        dx: ENTITY_VECTOR.dx * rand(0.2),
        dy: ENTITY_VECTOR.dy * rand(0.2),
        r: 250,
        g: 250,
        b: 0,
        a: 255}
    )
  }
end

init_entities
# / END INITIALIZE SECTION

def tick args
  handle_entities args

  render_interface args
  render_entities args
end

def distance entity_one, entity_two
  Math.sqrt(
      (entity_one.x - entity_two.x) * (entity_one.x - entity_two.x) +
        (entity_one.y - entity_two.y) * (entity_one.y - entity_two.y)
    )
end

def fly_towards entity
  center_x = 0.0
  center_y = 0.0
  neighbours_count = 0

  $gtk.args.state.entities.each do |other_entity|
    if distance(entity, other_entity) < VISUAL_RANGE
      center_x += other_entity.x
      center_y += other_entity.y
      neighbours_count += 1
    end
  end

  if neighbours_count != 0
    center_x = center_x / neighbours_count
    center_y = center_y / neighbours_count
    entity.dx += (center_x - entity.x) * CENTERING_FACTOR
    entity.dy += (center_y - entity.y) * CENTERING_FACTOR
  end

end

def avoid_others entity
  move_x = 0.0
  move_y = 0.0
  $gtk.args.state.entities.each do |other_entity|
    if entity != other_entity
      if (distance entity, other_entity) < MIN_DISTANCE
        move_x += entity.x - other_entity.x
        move_y += entity.y - other_entity.y
      end
    end
  end

  entity.dx += move_x * AVOID_FACTOR
  entity.dy += move_y * AVOID_FACTOR
end

def matching_velocity entity
  avg_dx = 0.0
  avg_dy = 0.0
  neighbours_count = 0

  $gtk.args.state.entities.each do |other_entity|
    if distance(entity, other_entity) < VISUAL_RANGE
      avg_dx += other_entity.dx
      avg_dy += other_entity.dy
      neighbours_count += 1
    end
  end

  if neighbours_count != 0
    avg_dx = avg_dx / neighbours_count
    avg_dy = avg_dy / neighbours_count

    entity.dx += (avg_dx * entity.dx) * MATCHING_FACTOR
    entity.dy += (avg_dy * entity.dy) * MATCHING_FACTOR
  end

end

def limit_speed entity
  speed = Math.sqrt(entity.dx * entity.dx + entity.dy * entity.dy)

  if speed > SPEED_LIMIT
    entity.dx = (entity.dx / speed) * SPEED_LIMIT
    entity.dy = (entity.dy / speed) * SPEED_LIMIT
  end
end

def keep_in_window entity, args
  turn_factor = 1.0

  if entity.x < args.state.screen_width.w
    entity.dx += turn_factor
  end

  if entity.x > entity.w - args.state.screen_width.w
    entity.dx -= turn_factor
  end

  if entity.y < args.state.screen_width.h
    entity.dy += turn_factor
  end

  if entity.y > entity.h - args.state.screen_width.h
    entity.dy -= turn_factor
  end

end

def handle_entities args
  args.state.entities.each do |entity|
    fly_towards entity
    avoid_others entity
    matching_velocity entity
    limit_speed entity
    keep_in_window entity, args

    entity.x += entity.dx
    entity.y += entity.dy
  end
end

# START RENDER SECTION
def render_entities args
  args.outputs.solids << args.state.entities
end

def render_interface args
  render_background args
  render_alive_zone args
  render_information args
end

def render_background args
  args.outputs.background_color = [100, 0, 100]
end

def render_alive_zone args
  args.outputs.solids << {x: 0, y: 0, w: args.state.screen_width.w, h: args.state.screen_width.h, r: 180, g: 0, b: 180}
end

def render_information args
  args.outputs.labels << [730, 680, "Enities count: #{args.state.entities.length}", 255, 255, 255]
end
# END RENDER SECTION