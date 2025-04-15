/*
  Warnings:

  - You are about to drop the column `cover` on the `Playlist` table. All the data in the column will be lost.
  - Added the required column `coverArt` to the `Playlist` table without a default value. This is not possible if the table is not empty.
  - Added the required column `description` to the `Playlist` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Playlist" DROP COLUMN "cover",
ADD COLUMN     "coverArt" TEXT NOT NULL,
ADD COLUMN     "description" TEXT NOT NULL;
