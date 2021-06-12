# Canvas API Basics

**General Form**

```json
{
    "operation": (Operation name),
    "details" : {
        // Operations details
    }
}
```



**Clear Rectangle**

Where x and y are the center of the rectangle.

[Reference](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/clearRect)

```json
{
    "operation": "clearRect",
    "details": {
        "x": 0,
        "y": 0,
        "width": 0,
        "height": 0
    }
}
```

**Fill Rectangle**

Where x and y are the center of the rectangle.

[Reference](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/fillRect)

```json
{
    "operation": "fillRect",
    "details": {
        "x": 0,
        "y": 0,
        "width": 0,
        "height": 0,
        "angle": 0
    }
}
```

**Stroke Rectangle**

Where x and y are the center of the rectangle.

[Reference](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/strokeRect)

```json
{
    "operation": "strokeRect",
    "details": {
        "x": 0,
        "y": 0,
        "width": 0,
        "height": 0,
        "angle": 0
    }
}
```

