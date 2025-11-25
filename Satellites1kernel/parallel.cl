// Stores 2D data like the coordinates
typedef struct{
   float x;
   float y;
} floatvector;

// Each float may vary from 0.0f ... 1.0f
typedef struct{
   float blue;
   float green;
   float red;
   float reserved;   // <— pad to 16 bytes
} color_f32;

// Stores the satellite data, which fly around black hole in the space
typedef struct{
   color_f32 identifier;
   floatvector position;
   floatvector velocity;
} satellite;

typedef struct {
    int   width;
    int   height;
    int   mouseX;
    int   mouseY;
    float blackHoleRadius2;
    float satelliteRadius2;
    int   satCount;
} GraphicsParams;

__kernel void graphics_render(__global const satellite* sats,
                     __constant GraphicsParams* P,
                     __global uchar4* pixels)
{
    const int gid = get_global_id(0);
    const int total = P->width * P->height;
    if (gid >= total) return;

    const int w = gid % P->width;
    const int h = gid / P->width;

    // Draw the black hole
    const float positionToBlackHoleX = (float)w - (float)P->mouseX;
    const float positionToBlackHoleY = (float)h - (float)P->mouseY;
    const float distToBlackHoleSquared =
       positionToBlackHoleX*positionToBlackHoleX +
       positionToBlackHoleY*positionToBlackHoleY;

    if (distToBlackHoleSquared < P->blackHoleRadius2) {
        pixels[gid] = (uchar4)(0,0,0,255);
        return;// Black hole drawing done
    }

    // This color is used for coloring the pixel
    float renderColorBlue=0.0f, renderColorGreen=0.0f, renderColorRed=0.0f;

    // Find closest satellite
    float shortestDistanceSquared = INFINITY;
    float weights = 0.0f;
    int hitsSatellite = 0;

    // First Graphics satellite loop: Find the closest satellite + accumulate total weight
    for (int j = 0; j < P->satCount; ++j) {
        const float differenceX = (float)w - sats[j].position.x;
        const float differenceY = (float)h - sats[j].position.y;
        const float distanceSquared = differenceX*differenceX +
                                      differenceY*differenceY;

        if (distanceSquared < P->satelliteRadius2) {
            renderColorBlue = 1.0f; // inside a satellite → white
            renderColorGreen = 1.0f;
            renderColorRed = 1.0f;
            hitsSatellite = 1;
            break;
        } else {
            const float weight = 1.0f / (distanceSquared * distanceSquared);   // ← fixed precedence
            weights += weight;

            if (distanceSquared < shortestDistanceSquared) {
                shortestDistanceSquared = distanceSquared;
                renderColorBlue = sats[j].identifier.blue;
                renderColorGreen = sats[j].identifier.green;
                renderColorRed = sats[j].identifier.red;
            }
        }
    }

    // Second graphics loop: Calculate the color based on distance to every satellite.
    if (!hitsSatellite) {
         float rb = 0.f, rg = 0.f, rr = 0.f;

         for(int k = 0; k < P->satCount; ++k){
            const float differenceX = (float)w - sats[k].position.x;
            const float differenceY = (float)h - sats[k].position.y;
            const float dist2 = differenceX*differenceX +
                                differenceY*differenceY;

            const float weight = 1.0f / (dist2 * dist2);

            rb += (sats[k].identifier.blue) * weight;
            rg += (sats[k].identifier.green) * weight;
            rr += (sats[k].identifier.red) * weight;
         }

         renderColorBlue += rb * 3.0f / weights;
         renderColorGreen += rg * 3.0f / weights;
         renderColorRed += rr * 3.0f / weights;
    }

    // clamp to the valid range before cast
    renderColorBlue  = clamp(renderColorBlue,  0.0f, 1.0f);
    renderColorGreen = clamp(renderColorGreen, 0.0f, 1.0f);
    renderColorRed   = clamp(renderColorRed,   0.0f, 1.0f);

    pixels[gid] = (uchar4)((uchar)(renderColorBlue*255.0f),
                           (uchar)(renderColorGreen*255.0f),
                           (uchar)(renderColorRed*255.0f),
                           (uchar)255);
}