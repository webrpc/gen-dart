package main

import (
	"context"
	"flutter_go/go_server/proto"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"time"
)

func main() {
	initialItems := []proto.Item{
		genItem("Cheese", proto.ItemTier_REGULAR),
		genItem("Romaine Lettuce", proto.ItemTier_PREMIUM),
		genItem("Iceberge Lettuce", proto.ItemTier_REGULAR),
		genItem("Heirloom Tomato", proto.ItemTier_PREMIUM),
		genItem("Hothouse Tomato", proto.ItemTier_REGULAR),
		genItem("White Bread", proto.ItemTier_REGULAR),
		genItem("Sourdough Bread", proto.ItemTier_PREMIUM),
		genItem("Mayonnaise", proto.ItemTier_REGULAR),
	}

	inventory := NewExampleServiceRPC(initialItems)
	webprcHandler := proto.NewExampleServiceServer(&inventory)
	http.Handle("/*", webprcHandler)

	var port string = os.Getenv("SERVICE_PORT")
	if port == "" {
		panic("Missing required environment variable SERVICE_PORT")
	}
	fmt.Printf("go_server listening on port %s\n", port)
	http.ListenAndServe(fmt.Sprintf(":%s", port), webprcHandler)
}

type ExampleServiceRPC struct {
	Items map[string]proto.Item
}

func NewExampleServiceRPC(initialItems []proto.Item) ExampleServiceRPC {
	if initialItems == nil {
		initialItems = []proto.Item{}
	}
	items := make(map[string]proto.Item)
	for _, item := range initialItems {
		items[item.Id] = item
	}
	return ExampleServiceRPC{Items: items}
}

// CreateItem implements proto.ExampleService.
func (e *ExampleServiceRPC) CreateItem(ctx context.Context, req *proto.CreateItemRequest) error {
	item := proto.Item{
		Id:        genKey(),
		Name:      req.Name,
		Tier:      req.Tier,
		Count:     0,
		CreatedAt: time.Now(),
	}
	e.Items[item.Id] = item
	return nil
}

// DeleteItem implements proto.ExampleService.
func (e *ExampleServiceRPC) DeleteItem(ctx context.Context, itemId string) error {
	_, exists := e.Items[itemId]
	if !exists {
		return proto.ErrNoSuchItem.WithCause(fmt.Errorf("no such item %s", itemId))
	}
	delete(e.Items, itemId)
	return nil
}

// GetItem implements proto.ExampleService.
func (e *ExampleServiceRPC) GetItem(ctx context.Context, itemId string) (*proto.Item, error) {
	result, exists := e.Items[itemId]
	if !exists {
		return nil, proto.ErrNoSuchItem.WithCause(fmt.Errorf("no such item %s", itemId))
	}
	return &result, nil
}

// GetItems implements proto.ExampleService.
func (e *ExampleServiceRPC) GetItems(ctx context.Context) ([]*proto.ItemSummary, error) {
	var result []*proto.ItemSummary
	for _, item := range e.Items {
		summary := proto.ItemSummary{
			Id:   item.Id,
			Name: item.Name,
		}
		result = append(result, &summary)
	}
	return result, nil
}

// PutOne implements proto.ExampleService.
func (e *ExampleServiceRPC) PutOne(ctx context.Context, itemId string) error {
	item, exists := e.Items[itemId]
	if !exists {
		return proto.ErrNoSuchItem.WithCause(fmt.Errorf("no such item %s", itemId))
	}
	item.Count += 1
	now := time.Now()
	item.LastUpdate = &now
	e.Items[itemId] = item
	return nil
}

// TakeOne implements proto.ExampleService.
func (e *ExampleServiceRPC) TakeOne(ctx context.Context, itemId string) error {
	item, exists := e.Items[itemId]
	if !exists {
		return proto.ErrNoSuchItem.WithCause(fmt.Errorf("no such item %s", itemId))
	} else if item.Count == 0 {
		return proto.ErrOutOfStock.WithCause(fmt.Errorf("item out of stock %s", itemId))
	}
	item.Count -= 1
	now := time.Now()
	item.LastUpdate = &now
	e.Items[itemId] = item
	return nil
}

var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

func genKey() string {
	b := make([]rune, 10)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func genItem(name string, tier proto.ItemTier) proto.Item {
	return proto.Item{
		Id:        genKey(),
		Name:      name,
		Tier:      tier,
		Count:     genCount(),
		CreatedAt: time.Now(),
	}
}

func genCount() uint32 {
	return uint32(rand.Intn(50))
}
