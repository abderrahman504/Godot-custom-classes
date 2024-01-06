using Godot;


[Tool]
[GlobalClass]
public partial class RegionMarker2D : Node2D
{

	Color _color = new Color(1,1,1,0.5f);
	Vector2 _size;

	[Export]
	public Color color{
		get{return _color;}
		set{ _color = value; QueueRedraw();}
	}
	[Export]
	public Vector2 Size{
		get{return _size;}
		set{ _size = value; QueueRedraw();}
	}

	public Vector2 End{
		get{return Position + Size;}
	}

	public override void _Draw()
	{
		if (Engine.IsEditorHint())
		{
			DrawRect(new Rect2(Vector2.Zero, Size), color, true);
			DrawRect(new Rect2(Vector2.Zero, Size), color, false, 2);
		}
	}

}