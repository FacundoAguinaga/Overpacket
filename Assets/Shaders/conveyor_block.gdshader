shader_type spatial;

// Declara una textura uniforme. 'source_color' le dice a Godot que use la textura
// albedo del material por defecto, si existe.
uniform sampler2D albedo_texture : source_color;

// La velocidad a la que se mueve la textura.
uniform float scroll_speed = 1.0;

void fragment() {
    // Crea una nueva variable para las coordenadas UV que se desplazarán.
    vec2 scrolling_uv = UV;
    
    // Desplaza la coordenada Y del UV a lo largo del tiempo.
    // Si tu textura se mueve en la otra dirección, cambia 'y' por 'x'.
    scrolling_uv.y -= TIME * scroll_speed;
    
    // Muestra la textura con las coordenadas UV desplazadas.
    ALBEDO = texture(albedo_texture, scrolling_uv).rgb;
}
