$gtk.args.state.entities ||= []

$gtk.args.state.screen_width ||= {w: 720.0, h: 720.0}

ENTITY_VECTOR = { dx: 2, dy: 2 }
ENTITY_SIZE = { w: 10, h: 10 }
ENTITIES_COUNT = 30
SPEED_LIMIT = 5

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

def handle_entities args
  args.state.entities.each do |entity|
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