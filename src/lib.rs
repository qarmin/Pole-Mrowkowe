use gdnative::prelude::*;

#[derive(NativeClass)]
#[inherit(Node)]
struct PoleMrowkowe;

#[gdnative::methods]
impl PoleMrowkowe {
    fn new(_owner: &Node) -> Self {
        PoleMrowkowe
    }

    #[export]
    fn _ready(&self, _owner: &Node) {
        godot_print!("Hello, world.")
    }
}

fn init(handle: InitHandle) {
    handle.add_class::<PoleMrowkowe>();
}

godot_init!(init);
